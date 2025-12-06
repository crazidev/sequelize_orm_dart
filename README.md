# Sequelize Dart

A Dart ORM for Sequelize.js integration with code generation support. Works seamlessly on both **Dart server** (via Node.js bridge) and **dart2js** (via JS interop).

## Features

- 🚀 **Dual Platform Support**: Works on Dart server and dart2js
- 📦 **Code Generation**: Automatic model implementation generation
- 🔌 **Multiple Databases**: PostgreSQL, MySQL, MariaDB support
- 🎯 **Type-Safe Queries**: Strongly-typed query builders
- 🔄 **Connection Pooling**: Built-in connection pool management
- 📝 **Annotations**: Simple, declarative model definitions

## Project Structure

This is a monorepo containing:

```
.
├── packages/
│   ├── sequelize_dart/               # Main package
│   │   └── README.md                  # [Package Documentation](./packages/sequelize_dart/README.md)
│   ├── sequelize_dart_annotations/    # Annotations package
│   │   └── README.md                  # [Package Documentation](./packages/sequelize_dart_annotations/README.md)
│   └── sequelize_dart_generator/     # Code generator
│       └── README.md                  # [Package Documentation](./packages/sequelize_dart_generator/README.md)
│
├── example/                           # Example project
│   ├── lib/
│   │   ├── main.dart
│   │   └── models/
│   └── migrations/                     # SQL migration files
│
├── tool/
│   └── setup_bridge.sh               # Bridge server setup script
│
└── README.md
```

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

### 4. Setup Bridge (Dart Server Only)

If running on Dart server, setup the bridge:

```bash
./tools/setup_bridge.sh [bun|pnpm|npm]
```

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

// MySQL
var sequelize = Sequelize().createInstance(
  MysqlConnection(
    url: 'mysql://user:password@localhost:3306/dbname',
    ssl: false,
  ),
);

// MariaDB
var sequelize = Sequelize().createInstance(
  MariadbConnection(
    url: 'mariadb://user:password@localhost:3306/dbname',
    ssl: false,
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
  equal('firstName', 'John'),
])

// OR
where: or([
  equal('id', 1),
  equal('id', 2),
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

### Complex Queries

```dart
var users = await Users.instance.findAll(
  Query(
    where: and([
      or([
        equal('email', 'user1@example.com'),
        equal('email', 'user2@example.com'),
      ]),
      notEqual('id', 0),
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

## Complete Example

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'models/users.model.dart';

Future<void> main() async {
  // Create Sequelize instance
  var sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: 'postgresql://postgres:postgres@localhost:5432/postgres',
      ssl: false,
      logging: (String sql) => false,
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

  // Create a user
  var newUser = await Users.instance.create({
    'email': 'john.doe@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
  });
  print('Created user: ${newUser.email}');

  // Find all users
  var allUsers = await Users.instance.findAll(
    Query(
      order: [['id', 'DESC']],
      limit: 10,
    ),
  );
  print('Found ${allUsers.length} users');

  // Find one user
  var user = await Users.instance.findOne(
    Query(
      where: equal('email', 'john.doe@example.com'),
    ),
  );
  print('Found user: ${user?.email}');

  // Close connection
  await sequelize.close();
  print('✅ Connection closed');
}
```

## Database Migrations

SQL migration files are provided in the `example/migrations/` directory:

- **MySQL**: `create_tables_mysql.sql`, `seed_data_mysql.sql`
- **PostgreSQL**: `create_tables_postgres.sql`, `seed_data_postgres.sql`

Run migrations manually:

```bash
# MySQL
mysql -u root -p dbname < example/migrations/create_tables_mysql.sql

# PostgreSQL
psql -U postgres -d dbname -f example/migrations/create_tables_postgres.sql
```

## Platform Differences

| Feature          | Dart Server           | dart2js             |
| ---------------- | --------------------- | ------------------- |
| **Setup**        | Requires bridge setup | No setup needed     |
| **Performance**  | Bridge overhead       | Native performance  |
| **Dependencies** | Bundled bridge        | Direct Sequelize.js |
| **API**          | Same API              | Same API            |

## Error Handling

```dart
try {
  var user = await Users.instance.findOne(
    Query(where: equal('id', 999)),
  );

  if (user == null) {
    print('User not found');
  }
} on BridgeException catch (e) {
  // Bridge-specific errors (Dart server only)
  print('Bridge error: ${e.message}');
  print('Original error: ${e.originalError}');
  if (e.sql != null) {
    print('SQL: ${e.sql}');
  }
} catch (e) {
  print('Error: $e');
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

- **[sequelize_dart](./packages/sequelize_dart/README.md)** - Main package documentation
- **[sequelize_dart_annotations](./packages/sequelize_dart_annotations/README.md)** - Annotations reference
- **[sequelize_dart_generator](./packages/sequelize_dart_generator/README.md)** - Code generator guide

## Development

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

## License

[Add your license here]
