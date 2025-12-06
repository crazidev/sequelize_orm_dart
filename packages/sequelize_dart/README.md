# sequelize_dart

A Dart ORM for Sequelize.js integration. Works on both Dart server (via Node.js bridge) and dart2js (via JS interop).

## Installation

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

## Platform Support

### Dart Server (Dart VM)

When running on Dart server, Sequelize Dart uses a Node.js bridge process to execute Sequelize.js operations. This allows you to use Sequelize.js features without requiring JS interop.

**Setup Required:**

1. Run the bridge setup script to bundle Sequelize.js:
   ```bash
   ./tools/setup_bridge.sh [bun|pnpm|npm]
   ```
2. The bridge server is automatically bundled and doesn't require `npm install` for end-users.

### dart2js (JavaScript Compilation)

When compiling to JavaScript with `dart2js`, Sequelize Dart uses JS interop to directly call Sequelize.js. This provides native performance in Node.js environments.

**No setup required** - works out of the box when compiled to JavaScript.

## Quick Start

### 1. Create a Model

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

### 2. Generate Model Code

```bash
dart run build_runner build
```

### 3. Connect to Database

#### PostgreSQL

```dart
import 'package:sequelize_dart/sequelize_dart.dart';

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

#### MySQL

```dart
var sequelize = Sequelize().createInstance(
  MysqlConnection(
    url: 'mysql://user:password@localhost:3306/dbname',
    ssl: false,
    logging: (String sql) => print(sql),
    pool: SequelizePoolOptions(
      max: 10,
      min: 2,
    ),
  ),
);
```

#### MariaDB

```dart
var sequelize = Sequelize().createInstance(
  MariadbConnection(
    url: 'mariadb://user:password@localhost:3306/dbname',
    ssl: false,
    pool: SequelizePoolOptions(
      max: 10,
      min: 2,
    ),
  ),
);
```

### 4. Authenticate and Register Models

```dart
await sequelize.authenticate();
sequelize.addModels([Users.instance]);
```

### 5. Query the Database

#### Find All Records

```dart
// Type-safe query with autocomplete
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.email.eq('user@example.com'),
    order: [['id', 'DESC']],
    limit: 10,
  ),
);

// Complex queries with type safety
var activeUsers = await Users.instance.findAll(
  (q) => Query(
    where: and([
      q.id.greaterThan(10),
      q.email.like('%@example.com'),
    ]),
    order: [
      ['lastName', 'ASC'],
      ['firstName', 'ASC'],
    ],
  ),
);
```

#### Find One Record

```dart
// Type-safe findOne
var user = await Users.instance.findOne(
  (q) => Query(
    where: q.id.eq(1),
  ),
);

// With multiple conditions
var userByEmail = await Users.instance.findOne(
  (q) => Query(
    where: and([
      q.email.eq('user@example.com'),
      q.id.greaterThan(0),
    ]),
  ),
);
```

#### Create Record

```dart
var newUser = await Users.instance.create({
  'email': 'newuser@example.com',
  'firstName': 'John',
  'lastName': 'Doe',
});
```

### 6. Clean Up

```dart
// Close the connection when done
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

// Advanced operators (using ComparisonOperator directly)
// The bridge server supports: $gt, $gte, $lt, $lte, $like, $ilike, $in, $notIn
// Example:
where: ComparisonOperator(
  column: 'age',
  value: {'$gt': 18},
)
```

### Type-Safe Queries

The generated model classes provide type-safe query builders with full autocomplete support:

```dart
// Type-safe queries with autocomplete
var users = await Users.instance.findAll(
  (q) => Query(
    where: and([
      or([
        q.email.eq('user1@example.com'),
        q.email.eq('user2@example.com'),
      ]),
      q.id.greaterThan(10),
    ]),
    order: [
      ['lastName', 'ASC'],
      ['firstName', 'ASC'],
    ],
    limit: 20,
    offset: 0,
  ),
);

// All operators are available on typed columns
var results = await Users.instance.findAll(
  (q) => Query(
    where: or([
      q.id.in_([1, 2, 3]),
      q.email.startsWith('admin'),
      q.firstName.like('%John%'),
    ]),
  ),
);
```

### Legacy Query Syntax (Still Supported)

For backward compatibility, you can still use the legacy syntax with string column names:

```dart
var users = await Users.instance.findAll(
  Query(
    where: and([
      or([
        equal('email', 'user1@example.com'),
        equal('email', 'user2@example.com'),
      ]),
      greaterThan('id', 10),
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

## Connection Pooling

Configure connection pooling for better performance:

```dart
pool: SequelizePoolOptions(
  max: 10,        // Maximum connections in pool
  min: 2,         // Minimum connections in pool
  idle: 10000,    // Idle timeout in milliseconds
  acquire: 60000, // Maximum time to get connection (ms)
  evict: 1000,    // Check for idle connections (ms)
)
```

## Error Handling

```dart
try {
  var user = await Users.instance.findOne(
    (q) => Query(where: q.id.eq(999)),
  );

  if (user == null) {
    print('User not found');
  }
} on BridgeException catch (e) {
  print('Bridge error: ${e.message}');
  print('Original error: ${e.originalError}');
} catch (e) {
  print('Error: $e');
}
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

  // Find all users with type-safe queries
  var allUsers = await Users.instance.findAll(
    (q) => Query(
      order: [['id', 'DESC']],
      limit: 10,
    ),
  );
  print('Found ${allUsers.length} users');

  // Find one user with type-safe query
  var user = await Users.instance.findOne(
    (q) => Query(
      where: q.email.eq('john.doe@example.com'),
    ),
  );
  print('Found user: ${user?.email}');

  // Close connection
  await sequelize.close();
  print('✅ Connection closed');
}
```

## API Reference

### Sequelize

- `createInstance(SequelizeCoreOptions)` - Create and configure Sequelize instance
- `authenticate()` - Verify database connection
- `addModels(List<Model>)` - Register models
- `close()` - Close database connection

### Model

- `findAll(Query Function(ModelQuery) builder)` - Find all records matching query (type-safe)
- `findOne(Query Function(ModelQuery) builder)` - Find one record matching query (type-safe)
- `create(Map<String, dynamic>)` - Create a new record

### Query

- `where` - Where conditions (using operators)
- `order` - Order by clauses `[['column', 'ASC|DESC']]`
- `limit` - Maximum number of records
- `offset` - Number of records to skip

## See Also

- [sequelize_dart_annotations](../sequelize_dart_annotations/README.md) - Annotations package
- [sequelize_dart_generator](../sequelize_dart_generator/README.md) - Code generator
