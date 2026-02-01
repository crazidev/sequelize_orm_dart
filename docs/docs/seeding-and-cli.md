---
sidebar_position: 10
---

# Seeding & CLI Reference

Sequelize Dart provides a powerful CLI and a programmatic API for database synchronization and seeding.

## `sequelize.yaml` Configuration

The `sequelize.yaml` file (placed in your project root) is used by the CLI to locate your models, seeders, and database connection profiles.

```yaml
# Path to your @Table model files
models_path: lib/db/models

# Path to your SequelizeSeeding files
seeders_path: lib/db/seeders

# Optional: Custom path for the generated model registry
# registry_path: lib/db.dart

# Database connection profiles
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

- **`models_path`**: (Required) Directory where the generator scans for `*.model.dart` files.
- **`seeders_path`**: (Required for seeding) Directory where the generator scans for `*.seeder.dart` files.
- **`connection` / `database`**: Define database profiles. You can have a single unnamed profile or multiple named profiles under `databases`.
- **`.env` Support**: Use `env.VAR_NAME` to resolve values from a `.env` file in your project root. This is the recommended way to handle sensitive credentials.

---

## CLI Seeding Usage

The CLI can automatically synchronize your database schema and execute all registered seeders.

```bash
dart run sequelize_dart_generator:generate --seed
```

### Options

| Option | Description |
|--------|-------------|
| `--url <url>` | Direct database connection URL. |
| `--database <name>` | Select a database profile from `sequelize.yaml`. |
| `--dialect <dialect>` | Override the dialect (postgres, mysql, mariadb, sqlite). |
| `--alter` / `--no-alter` | Whether to run `sync({alter: true})` before seeding. (Default: `true`) |
| `--force` / `--no-force` | Whether to run `sync({force: true})` (drops tables!) before seeding. (Default: `false`) |
| `--verbose` / `-v` | Show detailed logs, including SQL queries and seeder status. |

---

## Programmatic Seeding

You can run seeders directly from your code using the `sequelize.seed()` extension.

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
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
import 'package:sequelize_dart/sequelize_dart.dart';
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
