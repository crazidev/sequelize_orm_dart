Getting started with Sequelize Dart — a type-safe ORM for Dart powered by
[Sequelize.js](https://sequelize.org/) via a Node.js bridge.

## Prerequisites

**Node.js v18+** must be installed. Sequelize Dart uses a background Node.js
process to run Sequelize.js queries against your database.

```bash
node --version   # Should print v18.x.x or later
```

## Installation

```yaml
dependencies:
  sequelize_orm: ^0.1.4

dev_dependencies:
  sequelize_orm_generator: ^0.1.4
  build_runner: ^2.10.4
```

Then run `dart pub get`.

## Database Connection

```dart
import 'package:sequelize_orm/sequelize_orm.dart';

final sequelize = Sequelize().createInstance(
  connection: SequelizeConnection.postgres(
    host: 'localhost',
    port: 5432,
    database: 'my_database',
    user: 'postgres',
    password: 'postgres',
  ),
  logging: SqlFormatter.printFormatted,
);
```

Supported dialects: **PostgreSQL**, **MySQL**, **MariaDB**, **SQLite**.

## Define a Model

```dart
import 'package:sequelize_orm/sequelize_orm.dart';

part 'users.model.g.dart';

@Table(tableName: 'users', underscored: true)
class Users {
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

## Generate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates typed query builders, create/update DTOs, column references,
and include helpers.

## Basic Queries

```dart
// Create
final user = await Users.model.create(
  CreateUsers(email: 'alice@example.com', firstName: 'Alice', lastName: 'Smith'),
);

// Find all
final allUsers = await Users.model.findAll();

// Find one with where clause
final found = await Users.model.findOne(
  where: (u) => u.email.eq('alice@example.com'),
);

// Update
await Users.model.update(firstName: 'Alicia', where: (u) => u.id.eq(1));

// Aggregate
final count = await Users.model.count();
```
