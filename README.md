# Sequelize Dart

A Dart ORM for Sequelize.js integration with code generation support. Works seamlessly on both **Dart server** (via Node.js bridge) and **dart2js** (via JS interop).

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

### Dart Server (Dart VM)

When running on Dart server, Sequelize Dart uses a **Node.js bridge process** to execute Sequelize.js operations:

1. **Bridge Process**: A singleton Node.js process is spawned that runs Sequelize.js
2. **JSON-RPC Communication**: Dart communicates with the bridge via JSON-RPC over stdin/stdout
3. **Query Execution**: Queries are sent to the bridge, executed in Node.js, and results are streamed back
4. **Connection Pooling**: Managed by Sequelize.js in the bridge process

**Setup:**

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

```bash
# Generate model implementations
dart run build_runner build

# Or watch for changes
dart run build_runner watch
```

This creates `users.model.g.dart` with the generated `$Users` class.

**Note**: Not required for dart2js compilation.

### 5. Create Database Connection

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
```

### 6. Authenticate and Register Models

```dart
// Verify connection
await sequelize.authenticate();
print('✅ Connected to database');

// Register models
sequelize.addModels([Users.instance]);
```

### 7. Query the Database

```dart
// Type-safe queries with autocomplete
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.email.eq('user@example.com'),
    order: [['id', 'DESC']],
    limit: 10,
  ),
);

// Find one record
var user = await Users.instance.findOne(
  (q) => Query(
    where: q.id.eq(1),
  ),
);
```

### 8. Clean Up

```dart
// Close connection when done
await sequelize.close();
```

## Query Operators

### Logical Operators

```dart
// AND
where: and([
  equal('email', 'user@example.com'),
])

// OR
where: or([
  equal('id', 1),
])

// NOT
where: not([
  equal('email', 'admin@example.com'),
])
```

### Comparison Operators

```dart
// Equal
where: equal('id', 1)

// Not Equal
where: notEqual('id', 1)

// Advanced operators can be used via ComparisonOperator
// Bridge supports: $gt, $gte, $lt, $lte, $like, $ilike, $in, $notIn
```

### Type-Safe Queries

```dart
// Type-safe queries with full autocomplete support
var users = await Users.instance.findAll(
  (q) => Query(
    where: and([
      or([
        q.email.eq('user1@example.com'),
        q.email.eq('user2@example.com'),
      ]),
      q.id.ne(0),
    ]),
    order: [
      ['lastName', 'ASC'],
      ['firstName', 'ASC'],
    ],
    limit: 20,
    offset: 0,
  ),
);
```

## Platform Differences

| Feature          | Dart Server           | dart2js             |
| ---------------- | --------------------- | ------------------- |
| **Setup**        | Requires bridge setup | No setup needed     |
| **Performance**  | Bridge overhead       | Native performance  |
| **Dependencies** | Bundled bridge        | Direct Sequelize.js |
| **API**          | Same API              | Same API            |

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

- **[Get Started](./doc/get-started.md)** - Installation, database connection, and basic usage
- **[Models & Tables](./doc/models.md)** - Model definitions and configuration
- **[Associations](./doc/associations.md)** - Model relationships
- **[Querying](./doc/querying.md)** - Data querying and manipulation

### Building Documentation

```bash
# Build the documentation site
./tools/generate_docs.sh

# Or start the development server
cd website && npm start
```

### Package Documentation

- **[sequelize_dart](./packages/sequelize_dart/README.md)** - Main package documentation
- **[sequelize_dart_annotations](./packages/sequelize_dart_annotations/README.md)** - Annotations reference
- **[sequelize_dart_generator](./packages/sequelize_dart_generator/README.md)** - Code generator guide

## Development

### Setting Up Git Hooks

Install git hooks to automatically format code before committing:

```bash
./tools/setup-git-hooks.sh
```

This installs:

- **pre-commit**: Formats code automatically before each commit
- **pre-push**: Checks formatting before pushing (prevents unformatted code)

### Building the Bridge Server

```bash
# Setup bridge (installs dependencies and builds bundle)
./tools/setup_bridge.sh [bun|pnpm|npm]

# The bundle is created at:
# packages/sequelize_dart/js/bridge_server.bundle.js
```

### Running Examples

```bash
# Run example on Dart server
cd example
dart run lib/main.dart

# Compile to JavaScript and run
dart compile js lib/main.dart -o main.js
node main.js
```
