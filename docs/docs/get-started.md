---
sidebar_position: 1
---

# Get Started with Sequelize Dart

Welcome to Sequelize Dart! This guide will help you get started with using Sequelize Dart in your Dart projects.

## Installation

Add Sequelize Dart to your `pubspec.yaml`:

```yaml
dependencies:
  sequelize_dart: ^1.0.0
  sequelize_dart_annotations: ^1.0.0

dev_dependencies:
  sequelize_dart_generator: ^1.0.0
  build_runner: ^2.4.0
```

Then run:

```bash
dart pub get
```

### Setup for Dart VM (server-side)

If you're running on Dart VM (server-side), you need to build the server bundle:

```bash
# From the project root
./tools/setup_bridge.sh [bun|pnpm|npm]
```

This creates a bundled JavaScript file that allows Dart to communicate with Sequelize.js when running on the Dart VM.

## Database Connection

Sequelize Dart supports PostgreSQL, MySQL, MariaDB, SQLite, MS SQL Server, and DB2. Here's how to set up a connection:

```dart
import 'package:sequelize_dart/sequelize_dart.dart';

void main() async {
  // Create Sequelize instance with PostgreSQL connection
  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(
      url: 'postgresql://username:password@localhost:5432/database_name',
    ),
    // Optional: Enable SQL logging
    logging: (sql) => SqlFormatter.printFormatted(sql),
  );

  // Initialize with your models
  await sequelize.initialize(
    models: [
      // Add your models here
    ],
  );

  // Your code here...

  // Close connection when done
  await sequelize.close();
}
```

## Models & Tables

Models in Sequelize Dart are defined using annotations. Here's a basic example:

```dart
import 'package:sequelize_dart/sequelize_dart.dart';

part 'users.model.g.dart';

@Table(tableName: 'users', underscored: true)
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

After defining your model, generate the implementation code:

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
import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/models/user.model.dart';

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
