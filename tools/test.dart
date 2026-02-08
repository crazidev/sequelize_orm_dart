import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    print('Usage: dart tools/test.dart [flags] [test_files]');
    print('Flags:');
    print('  --postgres  Run tests using PostgreSQL (default)');
    print('  --mysql     Run tests using MySQL');
    print('  --mariadb   Run tests using MariaDB');
    print('  --all       Run tests for all supported databases');
    return;
  }

  final testFiles = args.where((arg) => !arg.startsWith('--')).toList();
  final flags = args.where((arg) => arg.startsWith('--')).toList();

  final databases = <String>[];
  if (flags.contains('--all')) {
    databases.addAll(['postgres', 'mysql', 'mariadb']);
  } else {
    if (flags.contains('--postgres')) databases.add('postgres');
    if (flags.contains('--mysql')) databases.add('mysql');
    if (flags.contains('--mariadb')) databases.add('mariadb');
  }

  if (databases.isEmpty && flags.isEmpty && testFiles.isEmpty) {
    // Default to postgres if no flags/files
    databases.add('postgres');
  } else if (databases.isEmpty) {
    // If files specified but no DB flag, default to postgres
    databases.add('postgres');
  }

  // Find all test files if none specified
  var filesToRun = testFiles;
  if (filesToRun.isEmpty) {
    filesToRun = findTestFiles(Directory('test'));
  }

  if (filesToRun.isEmpty) {
    print('No test files found.');
    return;
  }

  for (final db in databases) {
    print('\n${'=' * 60}');
    print('RUNNING TESTS FOR: ${db.toUpperCase()}');
    print('=' * 60 + '\n');

    for (final file in filesToRun) {
      print('Running: $file');

      final testArgs = ['test', '--concurrency=1', file];

      final result = await Process.run(
        'dart',
        testArgs,
        environment: {'DB_TYPE': db},
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      stdout.write(result.stdout);
      stderr.write(result.stderr);

      if (result.exitCode != 0) {
        print('\n[ERROR] Tests failed for $db in $file');
        exit(result.exitCode);
      }

      // Small delay between suites for better isolation/database cleanup
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  print('\n[SUCCESS] All tests passed for: ${databases.join(", ")}');
}

List<String> findTestFiles(Directory dir) {
  final files = <String>[];
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('_test.dart')) {
      files.add(entity.path);
    }
  }
  return files;
}
