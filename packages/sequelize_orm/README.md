# sequelize_orm

A type-safe ORM for Dart powered by Sequelize. Define models with annotations, generate query builders with code generation, and interact with PostgreSQL, MySQL, MariaDB, SQLite, and MSSQL databases from Dart.

**[Visit Documentation](https://sequelize-orm-dart.vercel.app/docs/get-started)**

## Features

- **Multi-database support** -- PostgreSQL, MySQL, MariaDB, SQLite, MSSQL
- **Code generation** -- Type-safe model classes, query builders, and model registry via `build_runner`
- **Declarative models** -- Define tables with `@Table`, `@PrimaryKey`, `@NotNull`, and other annotations
- **Associations** -- HasOne, HasMany, BelongsTo relationships with eager loading
- **Type-safe queries** -- Filtering, sorting, pagination, and aggregations with full IDE autocomplete
- **Dual platform** -- Works on Dart VM and dart2js

## Prerequisites

Sequelize Dart uses a Node.js bridge to communicate with the [Sequelize.js](https://sequelize.org/) runtime. You must have **Node.js** installed on your system before using this package.

- **Node.js** v18 or later -- [Download from nodejs.org](https://nodejs.org/)

Verify your installation:

```bash
node --version
```

## Installation

Add `sequelize_orm` to your dependencies and the generator to your dev dependencies:

```yaml
dependencies:
  sequelize_orm: ^0.1.0

dev_dependencies:
  sequelize_orm_generator: ^0.1.0
  build_runner: latest
```

Or you can run the following command:

```bash
dart pub add sequelize_orm dev:sequelize_orm_generator dev:build_runner
```

### build.yaml

Create a `build.yaml` in your project root to enable the generators:

```yaml
targets:
  $default:
    builders:
      sequelize_orm_generator|sequelize_model_builder:
        enabled: true
      sequelize_orm_generator|models_registry_builder:
        enabled: true
```

## Quick start

### 1. Define a model

Create a model file with the `.model.dart` suffix (e.g. `lib/models/users.model.dart`):

```dart
import 'package:sequelize_orm/sequelize_orm.dart';

part 'users.model.g.dart';

@Table(tableName: 'users', underscored: true)
abstract class Users {
  @PrimaryKey()
  @AutoIncrement()
  @NotNull()
  DataType id = DataType.INTEGER;

  @NotNull()
  DataType email = DataType.STRING;

  @ColumnName('first_name')
  @NotNull()
  DataType firstName = DataType.STRING;

  @ColumnName('last_name')
  DataType lastName = DataType.STRING;

  static UsersModel get model => UsersModel();
}
```

### 2. Create a model registry

Create a file named `db.registry.dart` in your models directory (e.g. `lib/models/db.registry.dart`). The file can be empty -- the generator uses it as a trigger to discover all `*.model.dart` files and produce a centralized registry class.

```dart
// lib/models/db.registry.dart
// This file triggers the models registry generator.
// It will generate db.dart with a Db class.
```

The generated `db.dart` provides:

```dart
class Db {
  static UsersModel get users => UsersModel();
  static List<Model> allModels() => [Db.users];
}
```

### 3. Run code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

This produces `*.model.g.dart` files for each model and the `db.dart` registry.

### 4. Connect to a database

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:myapp/models/db.dart';

Future<void> main() async {
  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(
      host: 'localhost',
      port: 5432,
      database: 'my_database',
      user: 'postgres',
      password: 'password',
    ),
    logging: (sql) => SqlFormatter.printFormatted(sql),
  );

  // Initialize all models from the generated registry
  await sequelize.initialize(
    models: Db.allModels(),
  );

  // ... run queries ...

  await sequelize.close();
}
```

### 5. Create and query records

```dart
// Create a new user
final newUser = await Db.users.create(
  CreateUsers(
    email: 'alice@example.com',
    firstName: 'Alice',
    lastName: 'Smith',
  ),
);
print('Created user: ${newUser.id}');

// Find all users
final users = await Db.users.findAll();
for (final user in users) {
  print('${user.firstName} ${user.lastName} (${user.email})');
}

// Find a single user by condition
final user = await Db.users.findOne(
  where: (u) => u.email.equals('alice@example.com'),
);
print('Found: ${user?.firstName}');

// Find by primary key
final userById = await Db.users.findByPrimaryKey(1);
```

## Supported databases

| Database   | Factory method                    |
| ---------- | --------------------------------- |
| PostgreSQL | `SequelizeConnection.postgres()`  |
| MySQL      | `SequelizeConnection.mysql()`     |
| MariaDB    | `SequelizeConnection.mariadb()`   |
| SQLite     | `SequelizeConnection.sqlite()`    |
| MSSQL      | `SequelizeConnection.mssql()`     |

You can connect using individual parameters or a connection URL:

```dart
// URL-based connection
SequelizeConnection.postgres(
  url: 'postgresql://user:pass@localhost:5432/dbname',
)

// Parameter-based connection
SequelizeConnection.mysql(
  host: 'localhost',
  database: 'my_db',
  user: 'root',
  password: 'secret',
)
```

## Documentation

For complete documentation including associations, advanced querying, filtering, seeding, and more:

**[Full Documentation](https://sequelize-orm-dart.vercel.app)**

The documentation covers:

- [Defining models](https://sequelize-orm-dart.vercel.app/docs/models/defining-models) -- Table options, column annotations, data types
- [Model registry](https://sequelize-orm-dart.vercel.app/docs/models/models-registry) -- Centralized model access
- [Associations](https://sequelize-orm-dart.vercel.app/docs/associations) -- HasOne, HasMany, BelongsTo
- [Querying](https://sequelize-orm-dart.vercel.app/docs/querying) -- Select, insert, update, delete, aggregations
- [Database connections](https://sequelize-orm-dart.vercel.app/docs/databases) -- All supported dialects and options

## See also

- [sequelize_orm_generator](https://pub.dev/packages/sequelize_orm_generator) -- Code generation package
- [Sequelize.js](https://sequelize.org/) -- The underlying JS ORM
