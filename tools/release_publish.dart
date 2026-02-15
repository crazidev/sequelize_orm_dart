/// Release & publish automation for sequelize_orm packages.
///
/// Usage:
///   dart run tools/release_publish.dart                  # dry-run (default)
///   dart run tools/release_publish.dart --publish        # publish to pub.dev
///   dart run tools/release_publish.dart --publish --tag  # publish + git tags
///   dart run tools/release_publish.dart --publish --tag --github-release
///
/// Flow:
///   1. Validate clean git tree & correct branch
///   2. Merge dev -> main (unless already on main with no pending merge)
///   3. Run publish (dry-run or real via melos)
///   4. Optionally create package-scoped git tags
///   5. Optionally create GitHub releases with changelog bodies
///
/// Note: dart doc is generated automatically by pub.dev on publish.
/// The dartdoc_options.yaml and {@category} annotations in source
/// control how docs appear on pub.dev.
library;

import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

/// Packages that get published.
const packages = <_Package>[
  _Package(
    name: 'sequelize_orm',
    path: 'packages/sequelize_orm',
  ),
  _Package(
    name: 'sequelize_orm_generator',
    path: 'packages/sequelize_orm_generator',
  ),
];

/// Repository URL used for GitHub release creation.
const repoSlug = 'crazidev/sequelize_orm_dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main(List<String> args) async {
  final doPublish = args.contains('--publish');
  final doTag = args.contains('--tag');
  final doGithubRelease = args.contains('--github-release');
  final skipMerge = args.contains('--skip-merge');

  _info('sequelize_orm release tool');
  _info('─────────────────────────────────────────');
  _info('  publish : $doPublish');
  _info('  tag     : $doTag');
  _info('  gh rel  : $doGithubRelease');
  _info('  merge   : ${!skipMerge}');
  _info('─────────────────────────────────────────');

  try {
    // ── Pre-flight ──────────────────────────────────────────────────────
    await _ensureToolsAvailable();
    await _ensureCleanTree();

    if (!skipMerge) {
      await _mergeDevToMain();
    } else {
      _info('Skipping merge (--skip-merge)');
    }

    // ── Publish ─────────────────────────────────────────────────────────
    if (doPublish) {
      _info('\nPublishing packages...');
      await _publish();
    } else {
      _info('\nRunning publish dry-run...');
      await _publishDryRun();
      _info(
        '\nDry-run complete. Re-run with --publish for actual publishing.',
      );
    }

    // ── Tags ────────────────────────────────────────────────────────────
    if (doTag || doGithubRelease) {
      _info('\nCreating package-scoped git tags...');
      for (final pkg in packages) {
        await _createTag(pkg);
      }
    }

    // ── GitHub Releases ─────────────────────────────────────────────────
    if (doGithubRelease) {
      if (await _isToolAvailable('gh')) {
        _info('\nCreating GitHub releases...');
        // Create in reverse order so the main package (sequelize_orm)
        // is created last and appears first on the GitHub releases page.
        for (final pkg in packages.reversed) {
          await _createGithubRelease(pkg);
        }
      } else {
        _info('\nSkipping GitHub releases: gh CLI is not installed.');
        _info('  Install it from https://cli.github.com/ then re-run with --github-release');
      }
    }

    _info('\nRelease completed successfully!');
  } catch (e, st) {
    stderr.writeln('\n[ERROR] $e');
    stderr.writeln(st);
    exitCode = 1;
  }
}

// ---------------------------------------------------------------------------
// Package descriptor
// ---------------------------------------------------------------------------

class _Package {
  const _Package({required this.name, required this.path});

  final String name;
  final String path;

  /// Read the version string from the package's pubspec.yaml.
  String get version {
    final pubspec = File('$path/pubspec.yaml');
    if (!pubspec.existsSync()) {
      throw StateError('pubspec.yaml not found at $path');
    }
    final lines = pubspec.readAsLinesSync();
    for (final line in lines) {
      final match = RegExp(r'^version:\s*(.+)$').firstMatch(line);
      if (match != null) return match.group(1)!.trim();
    }
    throw StateError('No version field found in $path/pubspec.yaml');
  }

  /// Tag name following monorepo convention: `<package>-v<version>`.
  String get tagName => '$name-v$version';

  /// pub.dev URL for this specific version.
  String get pubUrl => 'https://pub.dev/packages/$name/versions/$version';

  /// Extract the latest changelog section (everything between the first two
  /// `## ` headings, or until end-of-file if there is only one).
  String get latestChangelog {
    final changelog = File('$path/CHANGELOG.md');
    if (!changelog.existsSync()) return 'No changelog found.';

    final lines = changelog.readAsLinesSync();
    final buf = StringBuffer();
    var foundFirst = false;
    for (final line in lines) {
      if (line.startsWith('## ')) {
        if (foundFirst) break; // stop at next version heading
        foundFirst = true;
        buf.writeln(line);
        continue;
      }
      if (foundFirst) buf.writeln(line);
    }
    final body = buf.toString().trim();
    return body.isEmpty ? 'No changelog entries for this version.' : body;
  }

  /// Full release body for GitHub releases: changelog + pub.dev link.
  String get releaseBody {
    final changelog = latestChangelog;
    return '$changelog\n\n---\n\n'
        '**pub.dev**: $pubUrl';
  }
}

// ---------------------------------------------------------------------------
// Git helpers
// ---------------------------------------------------------------------------

Future<void> _ensureCleanTree() async {
  _info('Checking for clean working tree...');
  final status = (await _capture('git', ['status', '--porcelain'])).trim();
  if (status.isNotEmpty) {
    throw StateError(
      'Working tree is not clean. Commit or stash changes first.\n$status',
    );
  }
  _info('  Working tree is clean.');
}

Future<void> _mergeDevToMain() async {
  final branch =
      (await _capture('git', ['rev-parse', '--abbrev-ref', 'HEAD'])).trim();

  _info('Current branch: $branch');

  // If we're on dev, switch to main and merge.
  if (branch == 'dev') {
    _info('Fetching origin...');
    await _run('git', ['fetch', 'origin']);

    // Make sure main exists locally
    try {
      await _run('git', ['checkout', 'main']);
    } catch (_) {
      // main branch might not exist locally yet
      await _run('git', ['checkout', '-b', 'main', 'origin/main']);
    }

    await _run('git', ['pull', '--ff-only', 'origin', 'main']);

    _info('Merging dev into main...');
    await _run('git', ['merge', 'dev', '--no-edit']);

    _info('Pushing main to origin...');
    await _run('git', ['push', 'origin', 'main']);
  } else if (branch == 'main') {
    _info('Already on main.');
  } else {
    throw StateError(
      'Expected to be on "dev" or "main" branch, but found "$branch".\n'
      'Switch to dev or main before running release.',
    );
  }
}

Future<void> _createTag(_Package pkg) async {
  final tag = pkg.tagName;
  _info('  Tagging: $tag');

  // Check if the tag already exists
  final existing = (await _capture('git', ['tag', '-l', tag])).trim();
  if (existing.isNotEmpty) {
    _info('  Tag $tag already exists, skipping.');
    return;
  }

  await _run('git', ['tag', '-a', tag, '-m', 'Release ${pkg.name} ${pkg.version}']);
  await _run('git', ['push', 'origin', tag]);
}

// ---------------------------------------------------------------------------
// Publish
// ---------------------------------------------------------------------------

/// Check if a specific version of a package is already published on pub.dev
/// by querying the pub.dev API directly. Fast and doesn't hang.
Future<bool> _isAlreadyPublished(_Package pkg) async {
  try {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.parse('https://pub.dev/api/packages/${pkg.name}/versions/${pkg.version}'),
      );
      final response = await request.close();
      await response.drain<void>();
      return response.statusCode == 200;
    } finally {
      client.close();
    }
  } catch (_) {
    // Network error — assume not published, let publish handle it
    return false;
  }
}

Future<void> _publishDryRun() async {
  for (final pkg in packages) {
    if (await _isAlreadyPublished(pkg)) {
      _info('  ${pkg.name} v${pkg.version} already published, skipping.');
      continue;
    }
    _info('  Dry-run for ${pkg.name}...');
    await _run(
      'dart',
      ['pub', 'publish', '--dry-run'],
      workingDirectory: pkg.path,
    );
  }
}

Future<void> _publish() async {
  // Check if all packages are already published
  var allPublished = true;
  for (final pkg in packages) {
    if (await _isAlreadyPublished(pkg)) {
      _info('  ${pkg.name} v${pkg.version} already published, skipping.');
    } else {
      allPublished = false;
    }
  }

  if (allPublished) {
    _info('  All packages already published. Nothing to do.');
    return;
  }

  // Use melos publish which respects the package filters in pubspec.yaml
  await _run('dart', ['run', 'melos', 'publish', '--no-dry-run', '--yes']);
}

// ---------------------------------------------------------------------------
// GitHub releases (requires `gh` CLI)
// ---------------------------------------------------------------------------

Future<void> _createGithubRelease(_Package pkg) async {
  final tag = pkg.tagName;
  final body = pkg.releaseBody;

  _info('  Creating GitHub release for $tag...');
  _info('  Release body preview:');
  _info('  ${body.split('\n').first}...');
  _info('  pub.dev: ${pkg.pubUrl}');

  // Write release notes to a temp file to avoid shell escaping issues
  // with markdown special characters (#, *, `, etc.)
  final tempFile = File('.release_notes_${pkg.name}.md');
  try {
    tempFile.writeAsStringSync(body);
    await _run('gh', [
      'release',
      'create',
      tag,
      '--repo',
      repoSlug,
      '--title',
      '${pkg.name} ${pkg.version}',
      '--notes-file',
      tempFile.path,
    ]);
    _info('  GitHub release created for $tag');
  } finally {
    if (tempFile.existsSync()) tempFile.deleteSync();
  }
}

// ---------------------------------------------------------------------------
// Tool availability checks
// ---------------------------------------------------------------------------

Future<void> _ensureToolsAvailable() async {
  _info('Checking required tools...');

  // dart is guaranteed if we're running this script
  await _run('dart', ['--version']);

  // git
  await _run('git', ['--version']);

  _info('  All required tools available.');
}

/// Returns true if [tool] is available on the system PATH.
Future<bool> _isToolAvailable(String tool) async {
  try {
    final result = await Process.run(
      tool,
      ['--version'],
      runInShell: true,
    );
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Process helpers
// ---------------------------------------------------------------------------

Future<void> _run(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final display = [executable, ...arguments].join(' ');
  final cwdSuffix =
      workingDirectory != null ? ' (cwd: $workingDirectory)' : '';
  stdout.writeln('  \$ $display$cwdSuffix');

  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: true,
  );

  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  final code = await process.exitCode;
  if (code != 0) {
    throw ProcessException(executable, arguments, 'Exit code $code', code);
  }
}

Future<String> _capture(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: true,
  );
  if (result.exitCode != 0) {
    throw ProcessException(
      executable,
      arguments,
      '${result.stderr}',
      result.exitCode,
    );
  }
  return (result.stdout as String?) ?? '';
}

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------

void _info(String message) => stdout.writeln(message);
