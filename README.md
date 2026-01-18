# Sequelize Dart

A Dart ORM for Sequelize.js integration with code generation support. Works seamlessly on both **Dart server** (Dart VM) and **dart2js** (JavaScript compilation) via a unified Node.js bridge.

## Features

- 🚀 **Dual Platform Support**: Works on Dart server and dart2js
- 📦 **Code Generation**: Automatic model implementation generation
- 🔌 **Multiple Databases**: PostgreSQL, MySQL, MariaDB support
- 🎯 **Type-Safe Queries**: Strongly-typed query builders
- 🔄 **Connection Pooling**: Built-in connection pool management
- 📝 **Annotations**: Simple, declarative model definitions

## Packages

- **[sequelize_dart](./packages/sequelize_dart/README.md)** - Main ORM package with Sequelize.js integration
- **[sequelize_dart_annotations](./packages/sequelize_dart_annotations/README.md)** - Platform-independent annotations
- **[sequelize_dart_generator](./packages/sequelize_dart_generator/README.md)** - Code generator for model implementations

## How It Works

Sequelize Dart uses a **unified Node.js bridge** for both Dart VM and dart2js platforms. The bridge handles all Sequelize.js operations, ensuring consistent behavior across platforms.

## Quick Start

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  sequelize_dart: letest
  sequelize_dart_annotations: letest

dev_dependencies:
  sequelize_dart_generator:
    path: sequelize_dart_generator
  build_runner: ^2.10.4
```

### 2. Create a Model

```dart
// lib/models/user.model.dart
import 'package:sequelize_dart/sequelize_dart.dart';

part 'user.model.g.dart';

@Table(tableName: 'users', underscored: true)
class User {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @NotNull()
  DataType username = DataType.STRING;

  @ColumnName('email_address')
  DataType email = DataType.STRING;

  @ColumnName('is_active')
  DataType isActive = DataType.BOOLEAN;

  static $User get instance => $User();
}
```

### 3. Generate Model Code

```bash
# Generate model implementations
dart run build_runner build

# Or watch for changes
dart run build_runner watch
```

This creates `user.model.g.dart` with the generated `$User` class.

### 4. Create Database Connection

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
      User.instance,
    ],
  );

  // Create a new user
  final newUser = await User.instance.create(
    $UserCreate(
      username: 'johndoe',
      email: 'john@example.com',
      isActive: true,
    ),
  );

  // Find users
  final users = await User.instance.findAll();

  // Find one user
  final user = await User.instance.findOne(
    where: (user) => user.id.equals(1),
  );

  // Close connection when done
  await sequelize.close();
}
```

## Basic Querying

### Find Records

```dart
// Find all users
final users = await User.instance.findAll();

// Find users with conditions
final activeUsers = await User.instance.findAll(
  where: (user) => user.email.isNotNull(),
  limit: 10,
);

// Find one user
final user = await User.instance.findOne(
  where: (user) => user.email.equals('user@example.com'),
);
```

### Create Records

```dart
// Create using the generated helper class (Recommended)
final user = await User.instance.create(
  $UserCreate(
    username: 'johndoe',
    email: 'user@example.com',
    isActive: true,
  ),
);
```

### Update Records

```dart
// Update with named parameters
final affected = await User.instance.update(
  firstName: 'Jane',
  where: (user) => user.email.equals('user@example.com'),
);

// Update multiple fields
await User.instance.update(
  isActive: false,
  firstName: 'Jane',
  where: (user) => user.id.equals(1),
);
```

### Updating Instances

You can also update a model instance directly.

```dart
final user = await User.instance.findOne(where: (user) => user.id.eq(1));

if (user != null) {
  user.username = 'Updated Name';
  await user.save();
}
```

## Connection Pooling

Configure connection pooling for better performance and concurrency:

```dart
pool: SequelizePoolOptions(
  max: 10,        // Maximum connections in pool
  min: 2,         // Minimum connections in pool
  idle: 10000,    // Idle timeout in milliseconds
  acquire: 60000, // Maximum time to get connection (ms)
  evict: 1000,    // Check for idle connections (ms)
)
```

## Documentation

The documentation is built with [Docusaurus](https://docusaurus.io/) and includes comprehensive guides:

- **[Get Started](./docs/docs/get-started.md)** - Installation, database connection, and basic usage
- **[Database Connection](./docs/docs/databases.md)** - Connecting to PostgreSQL, MySQL, and MariaDB
- **[Models & Tables](./docs/docs/models.md)** - Model definitions and configuration
- **[Associations](./docs/docs/associations.md)** - Model relationships
- **[Querying](./docs/docs/querying.md)** - Data querying and manipulation

### Package Documentation

- **[sequelize_dart](./packages/sequelize_dart/README.md)** - Main package documentation
- **[sequelize_dart_annotations](./packages/sequelize_dart_annotations/README.md)** - Annotations reference
- **[sequelize_dart_generator](./packages/sequelize_dart_generator/README.md)** - Code generator guide
