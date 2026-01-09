# Development Workflow

This guide covers common development tasks for Sequelize Dart.

## Quick Reference

| Task            | Command                                     |
| --------------- | ------------------------------------------- |
| Build bridge    | `./tools/setup_bridge.sh`                   |
| Generate models | `cd example && dart run build_runner build` |
| Run tests       | `dart test`                                 |
| Format code     | `./tools/format.sh`                         |
| Build dart2js   | `./tools/build.sh --generate --run`         |
| Watch changes   | `./tools/watch.sh`                          |

## Initial Setup

### 1. Install Dependencies

```bash
# Install Dart dependencies
dart pub get

# Install example dependencies
cd example && dart pub get && cd ..

# Build bridge server bundle
./tools/setup_bridge.sh bun  # or npm, pnpm
```

### 2. Setup Git Hooks (Optional)

```bash
./tools/setup-git-hooks.sh
```

This installs pre-commit (auto-format) and pre-push (format check) hooks.

## Building the Bridge Server

The bridge server is a Node.js process that runs Sequelize.js for Dart VM environments.

```bash
# Build with bun (fastest)
./tools/setup_bridge.sh bun

# Build with npm
./tools/setup_bridge.sh npm

# Build with pnpm
./tools/setup_bridge.sh pnpm
```

This creates `packages/sequelize_dart/js/bridge_server.bundle.js`.

### Manual Bridge Building

```bash
cd packages/sequelize_dart/js

# Install dependencies
bun install  # or npm install

# Build bundle
bun run build  # or npm run build
```

### Bridge Development (Watch Mode)

For active bridge development:

```bash
cd packages/sequelize_dart/js
bun run dev  # or npm run dev
```

## Code Generation

### Generate All Models

```bash
cd example
dart run build_runner build --delete-conflicting-outputs
```

### Watch Mode

```bash
cd example
dart run build_runner watch --delete-conflicting-outputs
```

### Clean Generated Files

```bash
cd example
dart run build_runner clean
```

## Running Tests

### All Tests

```bash
# From project root
dart test

# With verbose output
dart test -r expanded
```

### Specific Test File

```bash
dart test test/operators/basic_comparison_test.dart
```

### Test Category

```bash
# All operator tests
dart test test/operators/

# All association tests
dart test test/associations/
```

### Test with Coverage

```bash
dart test --coverage=coverage
dart pub global run coverage:format_coverage \
  --lcov -i coverage -o coverage/lcov.info
```

## Running the Example

### Dart VM

```bash
cd example
dart run lib/main.dart
```

### dart2js (JavaScript)

```bash
# Build and run
./tools/build.sh --generate --run

# Or manually
dart compile js example/lib/main.dart -o example/build/temp.js
cat preamble.js example/build/temp.js > example/build/index.js
node example/build/index.js
```

## Formatting Code

### Format Everything

```bash
./tools/format.sh
```

### Format Dart Only

```bash
dart format .
```

### Format JS/TS Only

```bash
npx prettier --write "**/*.{js,ts,json,md}"
```

### Check Formatting (CI)

```bash
npm run format:check
```

## Linting

### Dart

```bash
dart analyze

# Auto-fix issues
dart fix --apply
```

### TypeScript

```bash
cd packages/sequelize_dart/js
npx tsc --noEmit
```

## Database Setup

### PostgreSQL (Docker)

```bash
docker run --name postgres-test \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=postgres \
  -p 5432:5432 \
  -d postgres:15
```

### MySQL (Docker)

```bash
docker run --name mysql-test \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=test \
  -p 3306:3306 \
  -d mysql:8
```

### Run Migrations

```bash
# PostgreSQL
psql -h localhost -U postgres -d postgres \
  -f example/migrations/create_tables_postgres.sql
psql -h localhost -U postgres -d postgres \
  -f example/migrations/seed_data_postgres.sql

# MySQL
mysql -h localhost -u root -proot test \
  < example/migrations/create_tables_mysql.sql
mysql -h localhost -u root -proot test \
  < example/migrations/seed_data_mysql.sql
```

## Adding New Features

### New Operator

1. Create extension in `packages/sequelize_dart/lib/src/query/operators/extentions/`
2. Export in `extensions.dart`
3. Add to `_getOpSymbol()` in `query_engine_js.dart`
4. Add to `convertWhereClause()` in `queryConverter.ts`
5. Write test in `test/operators/`

### New Query Method

See `.ai/QUERY_IMPLEMENTATION.md` for detailed steps.

### New Annotation Option

1. Add to `packages/sequelize_dart_annotations/lib/src/model_attribute.dart`
2. Update `toJson()` method
3. Update generator to use the new option
4. Update bridge if needed

### New Association Type

1. Create annotation in `sequelize_dart_annotations`
2. Update `_getAssociations()` in generator
3. Update `_generateAssociateModelMethod()`
4. Add to bridge handlers

## Troubleshooting

### Bridge Won't Start

```bash
# Check if bundle exists
ls -la packages/sequelize_dart/js/bridge_server.bundle.js

# Rebuild bridge
./tools/setup_bridge.sh

# Check Node.js version (requires v18+)
node --version
```

### Generated Code Issues

```bash
# Clean and regenerate
cd example
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# Check for analyzer errors
dart analyze example/
```

### Test Database Connection

```bash
# Check PostgreSQL connection
psql -h localhost -U postgres -d postgres -c "SELECT 1"

# Check MySQL connection
mysql -h localhost -u root -proot -e "SELECT 1"
```

### JS Interop Issues (dart2js)

```bash
# Check Sequelize.js is available
node -e "console.log(require('sequelize'))"

# Verify JS output
./tools/build.sh --generate
node example/build/index.js
```

## File Watching

### Watch All Changes

```bash
./tools/watch.sh
```

### Watch Dart Only

```bash
./tools/watch_dart.sh
```

### Watch TypeScript Only

```bash
./tools/watch_js.sh
```

## CI/CD Commands

```bash
# Install dependencies
dart pub get

# Analyze code
dart analyze --fatal-infos

# Check formatting
dart format --set-exit-if-changed .

# Run tests
dart test

# Build bridge (if needed)
./tools/setup_bridge.sh npm
```

## Version Management

### Update Package Versions

Edit `pubspec.yaml` in each package:

- `packages/sequelize_dart/pubspec.yaml`
- `packages/sequelize_dart_annotations/pubspec.yaml`
- `packages/sequelize_dart_generator/pubspec.yaml`

### Publish Packages

```bash
# Dry run first
dart pub publish --dry-run

# Publish
dart pub publish
```

## Performance Profiling

### Profile Query Execution

```dart
final stopwatch = Stopwatch()..start();
await Users.instance.findAll(where: (u) => u.id.eq(1));
print('Query took: ${stopwatch.elapsedMilliseconds}ms');
```

### Profile Bridge Communication

Enable detailed logging:

```dart
Sequelize().createInstance(
  PostgressConnection(
    url: connectionString,
    logging: (sql) {
      print('[SQL] $sql');
      print('[Time] ${DateTime.now()}');
    },
  ),
);
```

## Useful VS Code Tasks

Add to `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Bridge",
      "type": "shell",
      "command": "./tools/setup_bridge.sh",
      "group": "build"
    },
    {
      "label": "Generate Models",
      "type": "shell",
      "command": "dart run build_runner build --delete-conflicting-outputs",
      "options": { "cwd": "${workspaceFolder}/example" },
      "group": "build"
    },
    {
      "label": "Run Tests",
      "type": "shell",
      "command": "dart test",
      "group": "test"
    },
    {
      "label": "Format All",
      "type": "shell",
      "command": "./tools/format.sh",
      "group": "build"
    }
  ]
}
```
