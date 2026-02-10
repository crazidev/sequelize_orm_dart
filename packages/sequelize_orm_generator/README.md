# sequelize_orm_generator

Code generator for [sequelize_orm](https://pub.dev/packages/sequelize_orm). Generates type-safe model classes, query builders, create/update helpers, and a centralized model registry from annotated Dart classes using `build_runner`.

## Installation

Add the generator as a dev dependency alongside `build_runner`:

```yaml
dependencies:
  sequelize_orm: ^1.0.0

dev_dependencies:
  sequelize_orm_generator: ^1.0.0
  build_runner: ^2.4.0
```

### build.yaml

Create a `build.yaml` in your project root:

```yaml
targets:
  $default:
    builders:
      sequelize_orm_generator|sequelize_model_builder:
        enabled: true
      sequelize_orm_generator|models_registry_builder:
        enabled: true
```

## Running the generator

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (regenerates on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

## What gets generated

For each `*.model.dart` file, the generator produces a `*.model.g.dart` file containing:

### Model class (`UsersModel`)

The main model class with query methods:

| Method              | Description                       |
| ------------------- | --------------------------------- |
| `findAll()`         | Find all records matching filters |
| `findOne()`         | Find a single record              |
| `findByPrimaryKey()`| Find by primary key               |
| `create()`          | Create a new record               |
| `update()`          | Update matching records           |
| `count()`           | Count matching records            |
| `max()` / `min()`   | Column max/min value              |
| `sum()`             | Column sum                        |

### Values class (`UsersValues`)

Model instance with data fields and instance methods:

- `reload()` -- Refresh from database
- `save()` -- Persist changes
- `update()` -- Update fields
- `toJson()` / `fromJson()` -- Serialization

### Create helper (`CreateUsers`)

Type-safe class with named parameters for inserting records:

```dart
await Users.model.create(
  CreateUsers(
    email: 'user@example.com',
    firstName: 'John',
  ),
);
```

### Columns class (`UsersColumns`)

Type-safe column accessors for query building:

```dart
Users.model.findAll(
  where: (u) => u.email.equals('user@example.com'),
);
```

### Include helper (`UsersIncludeHelper`)

Helper for building association eager-loading:

```dart
Users.model.findAll(
  include: (include) => [include.posts()],
);
```

## Model registry

The generator also produces a centralized model registry. Create a `*.registry.dart` file (e.g. `lib/models/db.registry.dart`) and the generator will scan all `*.model.dart` files to produce a registry class:

| Registry file            | Generated class | Output file      |
| ------------------------ | --------------- | ---------------- |
| `db.registry.dart`       | `Db`            | `db.dart`        |
| `models.registry.dart`   | `Models`        | `models.dart`    |
| `database.registry.dart` | `Database`      | `database.dart`  |

The generated registry provides:

```dart
class Db {
  static UsersModel get users => UsersModel();
  static PostModel get post => PostModel();

  static List<Model> allModels() => [Db.users, Db.post];
}
```

Use it to initialize all models at once:

```dart
await sequelize.initialize(models: Db.allModels());
```

## CLI tools

The package provides two CLI commands:

### `generate` -- Code generation

```bash
# Generate all models and registry (default)
dart run sequelize_orm_generator:generate

# Generate a single model
dart run sequelize_orm_generator:generate --input lib/models/users.model.dart

# Generate models from a specific folder
dart run sequelize_orm_generator:generate --folder lib/models

# Generate only the registry
dart run sequelize_orm_generator:generate --registry
```

### `seed` -- Database seeding

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

## Configuration (sequelize.yaml)

Create a `sequelize.yaml` in your project root to customize paths and database connection profiles:

```yaml
# Used by both generate and seed
models_path: lib/models
seeders_path: lib/seeders
registry_path: lib/db/db.dart

# Used by seed only
connection:
  default:
    dialect: postgres
    host: env.DB_HOST
    port: env.DB_PORT
    database: env.DB_NAME
    user: env.DB_USER
    pass: env.DB_PASS
```

The `generate` command reads only the path settings (`models_path`, `seeders_path`, `registry_path`). It does **not** load `.env` or resolve `env.` references.

The `seed` command loads a `.env` file from your project root and resolves `env.VAR` references in connection profiles. This keeps sensitive credentials out of version control.

## Troubleshooting

### Generated files not updating

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Import errors

Ensure your model file has the correct `part` directive matching the filename:

```dart
part 'users.model.g.dart';
```

### Build errors

- All annotations must be imported from `package:sequelize_orm/sequelize_orm.dart`
- Column fields must use the `DataType` enum
- The `@Table` annotation must have a `tableName` parameter (or use `underscored: true` for auto-naming)

## See also

- [sequelize_orm](https://pub.dev/packages/sequelize_orm) -- Main ORM package
- [Full documentation](https://sequelize-dart.dev) -- Guides and API reference
