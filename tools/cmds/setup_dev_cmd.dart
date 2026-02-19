part of '../run.dart';

/// Start PostgreSQL in Docker for development
Future<void> cmdSetupDev(Directory root) async {
  const container = 'sequelize_postgres_dev';
  cmdlog('Checking Docker...');
  final dockerCheck = await Process.run('docker', ['info'], runInShell: true);
  if (dockerCheck.exitCode != 0) {
    stderr.writeln('Docker is not running. Start Docker and try again.');
    exit(1);
  }

  await Process.run('docker', ['stop', container], runInShell: true);
  await Process.run('docker', ['rm', container], runInShell: true);

  cmdlog('Starting PostgreSQL container...');
  final runResult = await Process.run(
    'docker',
    [
      'run',
      '-d',
      '--name',
      container,
      '-e',
      'POSTGRES_DB=sequelize_dev',
      '-e',
      'POSTGRES_USER=dev_user',
      '-e',
      'POSTGRES_PASSWORD=dev_password',
      '-p',
      '5432:5432',
      'postgres:16-alpine',
    ],
    runInShell: true,
  );
  if (runResult.exitCode != 0) {
    stderr.write(runResult.stderr);
    exit(runResult.exitCode);
  }

  cmdlog('Waiting for PostgreSQL...');
  for (var i = 0; i < 30; i++) {
    await Future<void>.delayed(const Duration(seconds: 1));
    final ready = await Process.run(
      'docker',
      [
        'exec',
        container,
        'pg_isready',
        '-U',
        'dev_user',
        '-d',
        'sequelize_dev',
      ],
      runInShell: true,
    );
    if (ready.exitCode == 0) break;
    if (i == 29) {
      stderr.writeln('PostgreSQL did not become ready.');
      exit(1);
    }
  }

  final migrationsDir = Directory('${root.path}/example/migrations');
  final createSql = File('${migrationsDir.path}/create_tables_postgres.sql');
  final seedSql = File('${migrationsDir.path}/seed_data_postgres.sql');
  if (createSql.existsSync()) {
    cmdlog('Running migrations...');
    final p = await Process.start(
      'docker',
      [
        'exec',
        '-i',
        container,
        'psql',
        '-U',
        'dev_user',
        '-d',
        'sequelize_dev',
      ],
      runInShell: true,
    );
    await p.stdin.addStream(createSql.openRead());
    await p.stdin.close();
    await p.exitCode;
  }
  if (seedSql.existsSync()) {
    cmdlog('Seeding...');
    final p = await Process.start(
      'docker',
      [
        'exec',
        '-i',
        container,
        'psql',
        '-U',
        'dev_user',
        '-d',
        'sequelize_dev',
      ],
      runInShell: true,
    );
    await p.stdin.addStream(seedSql.openRead());
    await p.stdin.close();
    await p.exitCode;
  }

  cmdlog(
    'Dev environment ready. Connection: postgresql://dev_user:dev_password@localhost:5432/sequelize_dev',
  );
}
