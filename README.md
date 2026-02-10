# Sequelize Dart

**[Documentation](https://sequelize-orm-dart.vercel.app)** | **[Get Started](https://sequelize-orm-dart.vercel.app/docs/get-started)** | **[pub.dev](https://pub.dev/packages/sequelize_orm_dart)**

A Dart ORM for Sequelize.js integration with code generation support. Works seamlessly on both **Dart server** (Dart VM) and **dart2js** (JavaScript compilation) via a unified Node.js bridge.

## Features

- **Dual Platform Support**: Works on Dart server and dart2js
- **Code Generation**: Automatic model implementation generation
- **Multiple Databases**: PostgreSQL, MySQL, MariaDB support
- **Type-Safe Queries**: Strongly-typed query builders
- **Connection Pooling**: Built-in connection pool management
- **Annotations**: Simple, declarative model definitions

## Package Structure

This is a monorepo containing the following packages:

- **[sequelize_orm](./packages/sequelize_orm/)** - Main ORM package with Sequelize.js integration
- **[sequelize_orm_generator](./packages/sequelize_orm_generator/)** - Code generator for model implementations
- **[example](./example/)** - Example application demonstrating usage

## Project Structure

```
my_dart_server/
├── packages/
│   ├── sequelize_orm/              # Main ORM package
│   └── sequelize_orm_generator/    # Code generator
├── example/                          # Example application
├── docs/                            # Documentation (Docusaurus)
├── tools/                           # Development scripts
└── test/                            # Integration tests
```

## Getting Started

For quick start guide and usage examples, see:

- **[Main Package README](./packages/sequelize_orm/README.md)** - Quick start
- **[Documentation Site](https://sequelize-orm-dart.vercel.app)** - Full documentation

## Development Tools

### Available Scripts

The `tools/` directory contains development scripts:

- **`watch.sh`** - Watch models, compile to JS, and run with auto-reload
- **`watch_models.sh`** - Watch model files and regenerate code
- **`watch_dart.sh`** - Watch Dart files and restart Dart VM server
- **`watch_js.sh`** - Watch Dart files and recompile to JavaScript
- **`watch_bridge.sh`** - Watch TypeScript files and rebuild bridge bundles
- **`setup_bridge.sh`** - Build bridge server bundles
- **`build.sh`** - Compile Dart to JavaScript
- **`format.sh`** - Format all Dart files

### VSCode Tasks

Pre-configured tasks are available in `.vscode/tasks.json`:

#### Watch Tasks

- **1. Watch Models** - Regenerate code on model file changes
- **2. Watch Dart VM** - Restart Dart VM server on file changes
- **3. Watch dart2js** - Recompile to JavaScript on file changes
- **4. Watch Bridge** - Rebuild bridge bundles on TypeScript changes

#### Build Tasks

- **Build: Models** - Generate model code once
- **Build: Bridge** - Build bridge server bundles
- **Build: dart2js** - Compile main.dart to JavaScript
- **Build: Full** - Build everything (bridge → models → dart2js)

#### Run Tasks

- **Run: Dart VM** - Run example with Dart VM
- **Run: dart2js** - Run compiled JavaScript with Node.js
- **Run: Benchmark (Dart VM)** - Run performance benchmark
- **Run: Benchmark (dart2js)** - Run benchmark with Node.js

#### Compound Tasks

- **Watch: All** - Watch models, compile to JS, and run with auto-reload
- **Watch: Full Dev** - Watch models and run Dart VM server

Access tasks via: `Cmd+Shift+P` → "Tasks: Run Task"

## Development Guide

### Prerequisites

1. **Dart SDK**: Install [Dart SDK](https://dart.dev/get-dart) (^3.9.2 or higher)
2. **Node.js**: Install [Node.js](https://nodejs.org/) (v18+ recommended)
3. **Database**: PostgreSQL, MySQL, or MariaDB

### Setup

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd my_dart_server
   ```

2. **Install dependencies**:

   ```bash
   dart pub get
   ```

3. **Build the bridge server**:

   ```bash
   ./tools/setup_bridge.sh
   ```

4. **Generate model code**:

   ```bash
   cd example
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the example**:
   ```bash
   dart run lib/main.dart
   ```

### Development Workflow

1. **Use VSCode Tasks** for automated workflows (recommended)
   - Run "Watch: Full Dev" for complete development environment
   - Or use individual watch tasks as needed

2. **Manual workflow**:

   ```bash
   # Watch mode (regenerates on file changes)
   ./tools/watch_models.sh

   # In another terminal, run your app
   dart run example/lib/main.dart
   ```

### Running Tests

```bash
# Run all tests
dart test
```

## Seeding (experimental)

### Folder layout

- Models: `lib/db/models`
- Seeders: `lib/db/seeders` (files must end with `*.seeder.dart`)

### `pubspec.yaml` config

Add this to your package `pubspec.yaml`:

```yaml
sequelize_orm:
  models_path: lib/db/models
  seeders_path: lib/db/seeders
```

### Run seeders

```bash
# Generates model code + Db registry and then runs:
# - sequelize.initialize(models: Db.allModels())
# - sequelize.sync(alter: true)
# - runs Db.allSeeders() in order
dart run sequelize_orm_generator:generate --seed --url "postgresql://user:pass@localhost:5432/db"
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for contribution guidelines.
