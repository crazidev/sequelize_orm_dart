---
sidebar_position: 10
---

# Seeding & CLI Reference

Sequelize Dart provides two dedicated CLI commands and a programmatic API for code generation, database synchronization, and seeding.

## CLI Commands

### `generate` -- Code generation

The `generate` command produces `*.model.g.dart` files for each model and the model registry. It reads `sequelize.yaml` only for the `models_path`, `seeders_path`, and `registry_path` settings -- it does **not** load `.env` or use database connection profiles.

```bash
# Generate all models and registry (default)
dart run sequelize_orm_generator:generate

# Generate a single model
dart run sequelize_orm_generator:generate --input lib/models/users.model.dart

# Generate models from a specific folder
dart run sequelize_orm_generator:generate --folder lib/models

# Generate only the registry
dart run sequelize_orm_generator:generate --registry

# Watch mode (persistent stdio server)
dart run sequelize_orm_generator:generate --server
```

| Option | Description |
|--------|-------------|
| `--input <path>` | Single `*.model.dart` file to generate. |
| `--folder <path>` | Folder to scan for `**/*.model.dart`. |
| `--registry` | Generate only the `*.registry.dart` outputs. |
| `--output <path>` | Output path (only applies to `--input`). |
| `--server` | Run as a persistent stdio server (JSON lines). |
| `--package-root <path>` | Package root (defaults to nearest `pubspec.yaml`). |

### `seed` -- Database seeding

The `seed` command synchronizes your database schema and executes all registered seeders. It loads `.env` and resolves `env.VAR` references in `sequelize.yaml` connection profiles.

```bash
# Run seeders using the default profile
dart run sequelize_orm_generator:seed

# Run seeders with a database URL
dart run sequelize_orm_generator:seed --url postgresql://user:pass@localhost/db

# Run seeders with a specific profile from sequelize.yaml
dart run sequelize_orm_generator:seed --database dev

# Force sync before seeding (drops and recreates tables)
dart run sequelize_orm_generator:seed --force

# Verbose output
dart run sequelize_orm_generator:seed --verbose
```

| Option | Description |
|--------|-------------|
| `--url <url>` | Direct database connection URL. |
| `--database <name>` | Select a database profile from `sequelize.yaml`. |
| `--dialect <dialect>` | Override the dialect (postgres, mysql, mariadb, sqlite). |
| `--alter` / `--no-alter` | Whether to run `sync({alter: true})` before seeding. (Default: `true`) |
| `--force` / `--no-force` | Whether to run `sync({force: true})` (drops tables!) before seeding. (Default: `false`) |
| `--verbose` / `-v` | Show detailed logs, including SQL queries and seeder status. |

---

## `sequelize.yaml` Configuration

The `sequelize.yaml` file (placed in your project root) is used by the CLI to locate your models, seeders, and database connection profiles.

```yaml
# Path to your @Table model files (used by both generate and seed)
models_path: lib/db/models

# Path to your SequelizeSeeding files (used by both generate and seed)
seeders_path: lib/db/seeders

# Optional: Custom path for the generated model registry
# registry_path: lib/db.dart

# Database connection profiles (used by seed only)
connection:
  default:
    url: postgres://postgres@localhost:5432/postgres
  dev:
    dialect: postgres
    host: env.DB_HOST
    port: env.DB_PORT
    user: env.DB_USER
    password: env.DB_PASS
    database: env.DB_NAME
    ssl: false
```

### Configuration Options

- **`models_path`**: Directory where the generator scans for `*.model.dart` files. Used by both `generate` and `seed`.
- **`seeders_path`**: Directory where the generator scans for `*.seeder.dart` files. Used by both `generate` (for registry) and `seed` (for execution).
- **`registry_path`**: Optional custom output path for the generated registry file.
- **`connection` / `database`**: Define database profiles. You can have a single unnamed profile or multiple named profiles. **Used by `seed` only.**
- **`.env` support**: Use `env.VAR_NAME` to resolve values from a `.env` file in your project root. This is the recommended way to handle sensitive credentials. **Loaded by `seed` only** -- the `generate` command does not read `.env`.

---

## Programmatic Seeding

You can run seeders directly from your code using the `sequelize.seed()` extension.

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'lib/db/db.dart'; // Import your generated registry

void main() async {
  final sequelize = Sequelize().createInstance(...);

  // Initialize models first
  await sequelize.initialize(models: Db.allModels());

  // Run seeders
  await sequelize.seed(
    seeders: Db.allSeeders(),
    syncTableMode: SyncTableMode.alter,
    log: (msg) => print(msg),
  );
}
```

### `seed()` Parameters

- **`seeders`**: A list of `SequelizeSeeding` instances (usually provided by `Db.allSeeders()`).
- **`syncTableMode`**: Controls how tables are synchronized before seeding:
    - `SyncTableMode.alter`: Equivalent to `sync({alter: true})`.
    - `SyncTableMode.force`: Equivalent to `sync({force: true})`.
    - `SyncTableMode.none`: Skips synchronization.
- **`log`**: An optional callback `Function(String message)` to receive seeder progress notifications.

---

## Authoring Seeders

Seeders are classes that extend `SequelizeSeeding<TCreate>`, where `TCreate` is the generated create-type for your model (e.g., `CreateUser`).

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import '../db.dart';

class UserSeeder extends SequelizeSeeding<CreateUser> {
  @override
  int get order => 1; // Execution priority (ascending)

  @override
  SeederCreateFn<CreateUser> get create => Db.user.create;

  @override
  List<CreateUser> get seedData => [
    CreateUser(username: 'alice', isActive: true),
    CreateUser(username: 'bob', isActive: false),
  ];
}
```

- **`order`**: Numeric value to determine execution order. Lower numbers run first.
- **`create`**: The function used to insert data. Use the model's `create` method tear-off.
- **`seedData`**: A list of data objects to be inserted.

---

## Logging & Debugging

Sequelize Dart provides flexible logging for both SQL queries and internal setup processes.

### Redirection of Logs
When you provide a `logging` callback to `createInstance`, **all** SQL-related logs are redirected there, including:
- Standard SQL queries (`SELECT`, `INSERT`, etc.).
- Model definitions (`CREATE TABLE`).
- Association setup logs.

### Internal Debug Logging
The `debug` flag in `createInstance` enables internal diagnostic logs that help you verify that Sequelize is initializing correctly.

```dart
final sequelize = Sequelize().createInstance(
  connection: ...,
  logging: (sql) => print(sql),
  debug: true, // Enables "[Sequelize] Defining models..." logs
);
```
