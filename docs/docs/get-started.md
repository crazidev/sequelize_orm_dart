---
sidebar_position: 1
---

# Get Started with Sequelize Dart

Welcome to Sequelize Dart! This guide will help you get started with using Sequelize Dart in your Dart projects.

## Prerequisites

Sequelize Dart uses a Node.js bridge to communicate with the [Sequelize.js](https://sequelize.org/) runtime. You must have Node.js installed before using this package.

### Install Node.js

Download and install **Node.js v18 or later** from [nodejs.org](https://nodejs.org/).

Alternatively, use a version manager:

- **nvm** (macOS/Linux): [github.com/nvm-sh/nvm](https://github.com/nvm-sh/nvm)
- **nvm-windows** (Windows): [github.com/coreybutler/nvm-windows](https://github.com/coreybutler/nvm-windows)
- **fnm**: [github.com/Schniz/fnm](https://github.com/Schniz/fnm)

```bash
# Install with nvm
nvm install 18
nvm use 18

# Or install with fnm
fnm install 18
fnm use 18
```

Verify your installation:

```bash
node --version
# Should print v18.x.x or later
```

:::warning
Sequelize Dart will not work without Node.js. The ORM uses a background Node.js process to run Sequelize.js queries against your database.
:::

## Installation

Add Sequelize Dart to your `pubspec.yaml`:

```yaml
dependencies:
  sequelize_orm: ^0.1.5
  sequelize_orm_annotations: ^1.0.0

dev_dependencies:
  sequelize_orm_generator: ^0.1.5
  build_runner: ^2.4.0
```

Then run:

```bash
dart pub get
```
## Database Connection

Sequelize Dart supports PostgreSQL, MySQL, MariaDB, SQLite. Here's how to set up a connection:

```dart
import 'package:sequelize_orm/sequelize_orm.dart';

void main() async {
  // Create Sequelize instance with PostgreSQL connection
  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(
      url: 'postgresql://username:password@localhost:5432/database_name',
    ),
    logging: (sql) => SqlFormatter.printFormatted(sql),
  );

  // Initialize with your models
  await sequelize.initialize(
    models: [
      // Add your models here
    ],
  );

  await sequelize.close();
}
```

## Models & Tables

Models in Sequelize Dart are defined using annotations. Here's a basic example:

```dart
import 'package:sequelize_orm/sequelize_orm.dart';

part 'users.model.g.dart';

@Table()
class User {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @NotNull()
  DataType username = DataType.STRING;

  @ColumnName('is_active')
  DataType isActive = DataType.BOOLEAN;

  static UserModel get model => UserModel();
}

```

### Generating Model Code

We recommend using our optimized CLI for faster code generation:

```bash
dart run sequelize_orm_generator:generate
```

Alternatively, you can use standard `build_runner`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates the `*.model.g.dart` file that contains the model implementation.

## Basic Querying

### Create a Record

```dart
final newUser = await User.model.create({
  'username': 'johndoe',
  'isActive': true,
});
```

### Find Records

```dart
// Find all users
final users = await User.model.findAll();

// Find one user
final user = await User.model.findOne(
  where: User.model.id.equals(1),
);
```

### Update a Record

```dart
await User.model.update(
  data: {'isActive': false},
  where: User.model.id.equals(1),
);
```

## Complete Example

Here's a complete example putting it all together:

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/user.model.dart';

const connectionString = 'postgresql://postgres:postgres@localhost:5432/postgres';

Future<void> main() async {
  // Create Sequelize instance
  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(url: connectionString),
    logging: (sql) => SqlFormatter.printFormatted(sql),
  );

  // Initialize with models
  await sequelize.initialize(
    models: [
      User.model,
    ],
  );

  // Create a new user
  final newUser = await User.model.create({
    'username': 'johndoe',
    'isActive': true,
  });

  // Find the user
  final user = await User.model.findOne(
    where: User.model.id.equals(newUser.id),
  );

  print('Found user: ${user?.username}');

  // Update the user
  await User.model.update(
    data: {'isActive': false},
    where: User.model.id.equals(newUser.id),
  );

  // Find all users
  final allUsers = await User.model.findAll();
  print('Total users: ${allUsers.length}');

  // Close connection
  await sequelize.close();
}
```

## Next Steps

- Learn more about [Models & Tables](./models) - Detailed model configuration
- Explore [Associations](./associations) - Model relationships
- Discover advanced [Querying](./querying) techniques - Complete query reference
