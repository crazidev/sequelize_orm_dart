# Sequelize ORM – Tools

Cross-platform tooling for **Windows, macOS, and Linux**. All commands run via Dart so they work everywhere without Bash.

## Single entry point

```bash
dart run tools/run.dart <command> [options]
dart run tools/run.dart --help
```

Each command can be run **individually**. There is no need to run scripts from a shell.

## Commands

| Command         | Description |
|----------------|-------------|
| `build`        | Compile Dart to JS (default: `example/lib/main.dart` → `index.js`). Options: `--input=FILE`, `--output=NAME` |
| `setup-bridge` | Install and build bridge server. Use `bun`, `pnpm`, or `npm`; options: `--skip-install`, `--skip-cleanup` |
| `format`       | Format Dart and JS/JSON/MD (dart format + Prettier) |
| `watch-models` | Watch model files and run build_runner |
| `watch-dart`   | Watch Dart files and restart VM server on change |
| `watch-js`     | Watch Dart files and recompile to JS on change |
| `watch-bridge` | Watch TypeScript and rebuild bridge on change |
| `setup-dev`    | Start PostgreSQL in Docker for development |
| `setup-git-hooks` | Install git hooks from `.github/hooks` |
| `test`         | Run tests (forwards to `tools/test.dart`) |
| `release`      | Release/publish (forwards to `tools/release_publish.dart`) |
| `all-build`    | Full build: setup-bridge → models → dart2js |

## VS Code

- **Tasks**: Use **Terminal → Run Task**. All build and watch tasks call `dart run tools/run.dart` so they work on every OS.
- **Launch**: **Debug Node.js (dart2js)** uses the **Build: dart2js** task (which uses the tool). **Run Tests (tools)** runs `dart run tools/run.dart test`.

## Shell scripts (optional)

The `.sh` scripts in this directory are still present for Unix/macOS/Linux users who prefer to run `./tools/build.sh` or `./tools/watch_models.sh`. On Windows, use:

```powershell
dart run tools/run.dart build
dart run tools/run.dart watch-models
```

instead of the shell scripts.
