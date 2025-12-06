# Getting Started

Welcome to Sequelize Dart! This guide will help you get up and running quickly.

## What is Sequelize Dart?

Sequelize Dart is a Dart ORM (Object-Relational Mapping) library that provides seamless integration with Sequelize.js. It offers:

- 🚀 **Dual Platform Support**: Works on both Dart server (via Node.js bridge) and dart2js (via JS interop)
- 📦 **Code Generation**: Automatic model implementation generation with type safety
- 🔌 **Multiple Databases**: PostgreSQL, MySQL, and MariaDB support
- 🎯 **Type-Safe Queries**: Strongly-typed query builders with autocomplete
- 🔄 **Connection Pooling**: Built-in connection pool management
- 📝 **Simple Annotations**: Declarative model definitions

## Platform Support

### Dart Server (Dart VM)

When running on Dart server, Sequelize Dart uses a **Node.js bridge process** to execute Sequelize.js operations:

1. **Bridge Process**: A singleton Node.js process is spawned that runs Sequelize.js
2. **JSON-RPC Communication**: Dart communicates with the bridge via JSON-RPC over stdin/stdout
3. **Query Execution**: Queries are sent to the bridge, executed in Node.js, and results are streamed back
4. **Connection Pooling**: Managed by Sequelize.js in the bridge process

**Setup Required:**
```bash
# Build the bridge server bundle (one-time setup)
./tools/setup_bridge.sh [bun|pnpm|npm]
```

The bridge server is bundled into a single JavaScript file, so end-users don't need to run `npm install`.

### dart2js (JavaScript Compilation)

When compiling to JavaScript with `dart2js`, Sequelize Dart uses **JS interop** to directly call Sequelize.js:

1. **Direct Integration**: Uses `dart:js_interop` to call Sequelize.js APIs
2. **Native Performance**: No bridge overhead, direct function calls
3. **Same API**: Identical API surface for both platforms

**No setup required** - works out of the box when compiled to JavaScript.

## Quick Start

### 1. Add Dependencies

Add Sequelize Dart to your `pubspec.yaml`:

```yaml
dependencies:
  sequelize_dart:
    path: ../packages/sequelize_dart
  sequelize_dart_annotations:
    path: ../packages/sequelize_dart_annotations

dev_dependencies:
  sequelize_dart_generator:
    path: ../packages/sequelize_dart_generator
  build_runner: ^2.10.4
```

### 2. Create a Model

Create a model file with annotations:

```dart
// lib/models/users.model.dart
import 'package:sequelize_dart/sequelize_dart.dart';

part 'users.model.g.dart';

@Table(tableName: 'users')
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
    unique: true,
  )
  dynamic email;

  @ModelAttributes(
    name: 'firstName',
    type: DataType.STRING,
  )
  dynamic firstName;

  @ModelAttributes(
    name: 'lastName',
    type: DataType.STRING,
  )
  dynamic lastName;

  static $Users get instance => $Users();
}
```

### 3. Generate Model Code

Run the code generator:

```bash
dart run build_runner build
```

This creates `users.model.g.dart` with the generated `$Users` class.

### 4. Setup Bridge (Dart Server Only)

If running on Dart server, setup the bridge:

```bash
./tools/setup_bridge.sh [bun|pnpm|npm]
```

**Note**: Not required for dart2js compilation.

### 5. Connect to Database

```dart
import 'package:sequelize_dart/sequelize_dart.dart';

// PostgreSQL
var sequelize = Sequelize().createInstance(
  PostgressConnection(
    url: 'postgresql://user:password@localhost:5432/dbname',
    ssl: false,
    logging: (String sql) => print(sql),
    pool: SequelizePoolOptions(
      max: 10,
      min: 2,
      idle: 10000,
      acquire: 60000,
      evict: 1000,
    ),
  ),
);

// Authenticate
await sequelize.authenticate();
print('✅ Connected to database');

// Register models
sequelize.addModels([Users.instance]);
```

### 6. Query the Database

```dart
// Find all records
var allUsers = await Users.instance.findAll();

// Find with conditions
var users = await Users.instance.findAll(
  Query(
    where: equal('email', 'user@example.com'),
    order: [['id', 'DESC']],
    limit: 10,
  ),
);

// Find one record
var user = await Users.instance.findOne(
  Query(
    where: equal('id', 1),
  ),
);

// Create a record
var newUser = await Users.instance.create({
  'email': 'newuser@example.com',
  'firstName': 'John',
  'lastName': 'Doe',
});
```

### 7. Clean Up

```dart
// Close connection when done
await sequelize.close();
```

## Next Steps

- Learn about [Installation](./installation.md) and setup requirements
- Understand [Models](./models.md) and code generation
- Configure [Connections](./connections.md) for your database
- Explore [Querying](./querying.md) capabilities
- Check out [Examples](./examples.md) for common use cases

## Platform Differences

| Feature          | Dart Server           | dart2js             |
| ---------------- | --------------------- | ------------------- |
| **Setup**        | Requires bridge setup | No setup needed     |
| **Performance**  | Bridge overhead       | Native performance  |
| **Dependencies** | Bundled bridge        | Direct Sequelize.js |
| **API**          | Same API              | Same API            |
