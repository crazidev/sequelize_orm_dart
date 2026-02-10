# Sequelize Dart Tools

VS Code extension for generating Sequelize Dart model outputs via `build_runner`.

## Features

- **Generate model (this file)**: Right-click a `*.model.dart` file in the Explorer → "Sequelize Dart: Generate model (this file)"
- **Generate models (this folder)**: Right-click a folder or `*.model.dart` file → "Sequelize Dart: Generate models (this folder)"
- **Diagnostics + Quick Fix**: A diagnostic appears on the `@Table` class name when the corresponding `*.model.g.dart` file is missing or outdated. Use **Ctrl+.** (Quick Fix) to generate.
- **Build filter**: Uses `build_runner` with `--build-filter` to generate only the necessary output files.

## Configuration

Place a `sequelize_orm.yaml` or `sequelize_orm_tools.yaml` next to the nearest `pubspec.yaml` (or in the workspace root) to customize:

```yaml
generator:
  # analyzerServer (default) keeps a Dart analyzer process running per package.
  # buildRunner uses `dart run build_runner build --build-filter ...`.
  mode: analyzerServer

buildRunner:
  command: dart
  args: [run, build_runner, build, --delete-conflicting-outputs]
  extraArgs: []

analyzerServer:
  command: dart
  args: [run, sequelize_orm_generator:generate, --server]
  extraArgs: []

model:
  includeGlobs: ["**/*.model.dart"]
  generatedExtension: ".model.g.dart"
  partDirectiveRequired: true
```

## Development

1. `npm install`
2. `npm run compile`
3. Press **F5** in VS Code (with the sequelize_orm workspace open) to launch the Extension Development Host.

Or use the "Launch Sequelize Dart Tools Extension" configuration from the Run and Debug panel.
