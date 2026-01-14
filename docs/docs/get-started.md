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

### Setup Bridge Server (Dart VM only)

If you're running on Dart VM (server-side), you need to build the bridge server:

```bash
# From the project root
./tools/setup_bridge.sh [bun|pnpm|npm]
```

This creates a bundled JavaScript file that allows Dart to communicate with Sequelize.js via a Node.js bridge process.

## Database Connection

Sequelize Dart supports PostgreSQL, MySQL, and MariaDB. Here's how to set up a connection:

```dart
import 'package:sequelize_dart/sequelize_dart.dart';

void main() async {
  // Create Sequelize instance with PostgreSQL connection
  final sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: 'postgresql://username:password@localhost:5432/database_name',
      // Optional: Enable SQL logging
      logging: (String sql) => print(sql),
    ),
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
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

part 'users.model.g.dart';

@Table(
  tableName: 'users',
  underscored: true,
  timestamps: true,
)
class Users {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  )
  dynamic id;

  @ModelAttributes(
    name: 'email',
    type: DataType.STRING,
    allowNull: false,
  )
  dynamic email;

  @ModelAttributes(
    name: 'first_name',
    type: DataType.STRING,
  )
  dynamic firstName;

  @ModelAttributes(
    name: 'last_name',
    type: DataType.STRING,
  )
  dynamic lastName;

  static $Users get instance => $Users();
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
final newUser = await Users.instance.create({
  'email': 'user@example.com',
  'firstName': 'John',
  'lastName': 'Doe',
});
```

### Find Records

```dart
// Find all users
final users = await Users.instance.findAll();

// Find one user
final user = await Users.instance.findOne(
  where: Users.instance.id.equals(1),
);
```

### Update a Record

```dart
await Users.instance.update(
  data: {'firstName': 'Jane'},
  where: Users.instance.id.equals(1),
);
```

## Complete Example

Here's a complete example putting it all together:

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';

const connectionString = 'postgresql://postgres:postgres@localhost:5432/postgres';

Future<void> main() async {
  // Create Sequelize instance
  final sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: connectionString,
      logging: (String sql) => SqlFormatter.printFormatted(sql),
    ),
  );

  // Initialize with models
  await sequelize.initialize(
    models: [
      Users.instance,
    ],
  );

  // Create a new user
  final newUser = await Users.instance.create({
    'email': 'john@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
  });

  // Find the user
  final user = await Users.instance.findOne(
    where: Users.instance.id.equals(newUser.id),
  );

  print('Found user: ${user?.email}');

  // Update the user
  await Users.instance.update(
    data: {'firstName': 'Jane'},
    where: Users.instance.id.equals(newUser.id),
  );

  // Find all users
  final allUsers = await Users.instance.findAll();
  print('Total users: ${allUsers.length}');

  // Close connection
  await sequelize.close();
}
```

## Next Steps

- Learn more about [Models & Tables](./models) - Detailed model configuration
- Explore [Associations](./associations) - Model relationships
- Discover advanced [Querying](./querying) techniques - Complete query reference
