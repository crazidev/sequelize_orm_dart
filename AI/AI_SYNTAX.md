# Sequelize Dart - Syntax Reference

## Conditional Export Syntax

### Basic Pattern

```dart
// file: lib/src/component/component.dart
export 'component_stub.dart'
    if (dart.library.js_interop) 'component_js.dart'
    if (dart.library.io) 'component_dart.dart';
```

### Platform Detection

- `dart.library.js_interop` → JavaScript compilation (dart2js)
- `dart.library.io` → Dart VM (server)

## JS Interop Syntax

### Extension Types

```dart
// Define extension type for JS object
extension type SequelizeJS._(JSObject _) implements JSObject {
  @JS('authenticate')
  external JSPromise authenticate();

  @JS('define')
  external SequelizeModel define(
    JSString modelName,
    JSObject? attributes,
    JSObject? options,
  );

  @JS('close')
  external JSPromise close();
}

// Usage
final sequelize = sequelizeModule.sequelizeFn.callAsConstructor(config.jsify()) as SequelizeJS;
await sequelize.authenticate().toDart;
```

### JS Module Access

```dart
// Require JS module
SequelizeModule get sequelizeModule =>
    require('@sequelize/core') as SequelizeModule;

// Extension type for module
extension type SequelizeModule._(JSObject _) implements JSObject {
  @JS('Sequelize')
  external SequelizeJS get sequelize;

  @JS('DataTypes')
  external SequelizeDataTypes get dataTypes;

  @JS('Op')
  external SqOp get op;
}
```

### Value Conversion

```dart
// Dart to JS
String jsString = 'hello'.toJS;
int jsInt = 42.toJS;
bool jsBool = true.toJS;
JSObject jsObject = {'key': 'value'}.jsify() as JSObject;
JSArray jsArray = [1, 2, 3].jsify() as JSArray;

// JS to Dart
String dartString = jsString.toDart;
int dartInt = jsInt.toDart;
bool dartBool = jsBool.toDart;
dynamic dartObject = jsObject.dartify();
List<dynamic> dartArray = jsArray.toDart;
```

### Function Interop

```dart
// JS function with interop callback
config['logging'] = js.allowInterop((JSAny sql, JSAny? timing) {
  input.logging!(sql.toString());
});

// Calling JS methods
await model.findAll(options).toDart;
await sequelize.authenticate().toDart;
```

## Bridge Communication Syntax

### Bridge Client Usage

```dart
// Get singleton instance
final bridge = BridgeClient.instance;

// Start bridge with connection config
await bridge.start(connectionConfig: {
  'url': 'postgresql://user:pass@localhost:5432/db',
  'logging': true,
});

// Make JSON-RPC calls
final result = await bridge.call('findAll', {
  'model': 'users',
  'options': {
    'where': {'id': 1},
    'limit': 10,
  },
});

// Check connection state
if (bridge.isConnected) {
  // Safe to make calls
}

// Handle errors
try {
  final result = await bridge.call('method', params);
} catch (e) {
  if (e is BridgeException) {
    print('Bridge error: ${e.message}');
    print('Code: ${e.code}');
    print('Stack: ${e.stack}');
  }
}
```

### Bridge Method Signatures

```dart
// Model operations
await bridge.call('defineModel', {
  'name': 'users',
  'attributes': {
    'id': {'type': 'INTEGER', 'primaryKey': true},
    'email': {'type': 'STRING', 'allowNull': false},
  },
  'options': {'tableName': 'users'},
});

await bridge.call('associateModel', {
  'sourceModel': 'users',
  'targetModel': 'posts',
  'associationType': 'hasMany',
  'options': {'foreignKey': 'userId'},
});

// Query operations
await bridge.call('findAll', {
  'model': 'users',
  'options': query.toJson(),
});

await bridge.call('findOne', {
  'model': 'users',
  'options': query.toJson(),
});

await bridge.call('count', {
  'model': 'users',
  'options': query.toJson(),
});
```

## Model Definition Syntax

### Annotations

```dart
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
    allowNull: false,
    validate: {
      'isEmail': true,
    },
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

  @ModelAttributes(
    name: 'createdAt',
    type: DataType.DATE,
    autoCreatedAt: true,
  )
  dynamic createdAt;

  @ModelAttributes(
    name: 'updatedAt',
    type: DataType.DATE,
    autoUpdatedAt: true,
  )
  dynamic updatedAt;

  static $Users get instance => $Users();
}
```

### Association Annotations

```dart
// In User model
@HasMany(
  target: Post,
  foreignKey: 'userId',
  as: 'posts',
)
List<Post>? posts;

// In Post model
@BelongsTo(
  target: User,
  foreignKey: 'userId',
  as: 'user',
)
User? user;
```

## Query Builder Syntax

### Generated Query Class

```dart
class $Users {
  // Column accessors
  TypedColumn<Users, dynamic> get id => TypedColumn('id');
  TypedColumn<Users, String> get email => TypedColumn('email');
  TypedColumn<Users, String> get firstName => TypedColumn('firstName');
  TypedColumn<Users, String> get lastName => TypedColumn('lastName');
  TypedColumn<Users, DateTime> get createdAt => TypedColumn('createdAt');

  // Query methods
  Future<List<Users>> findAll(QueryBuilder<Users> Function($Users) builder) =>
    super.findAll((q) => builder(this));

  Future<Users?> findOne(QueryBuilder<Users> Function($Users) builder) =>
    super.findOne((q) => builder(this));
}
```

### Query Construction

```dart
// Basic queries
final users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.eq(1),
  ),
);

// Complex queries
final users = await Users.instance.findAll(
  (q) => Query(
    where: and([
      q.id.gt(10),
      q.email.like('%@example.com'),
      or([
        q.firstName.eq('John'),
        q.firstName.eq('Jane'),
      ]),
    ]),
    order: [
      ['lastName', 'ASC'],
      ['firstName', 'ASC'],
    ],
    limit: 20,
    offset: 0,
    attributes: QueryAttributes(['id', 'email', 'firstName']),
  ),
);
```

### Operator Syntax

```dart
// Comparison operators
q.id.eq(1)           // id = 1
q.id.ne(1)           // id != 1
q.id.gt(10)          // id > 10
q.id.gte(10)         // id >= 10
q.id.lt(10)          // id < 10
q.id.lte(10)         // id <= 10

// String operators
q.email.like('%@example.com')  // email LIKE '%@example.com'
q.email.iLike('%@example.com') // email ILIKE '%@example.com'
q.email.startsWith('john')      // email LIKE 'john%'
q.email.endsWith('@example.com') // email LIKE '%@example.com'

// Null operators
q.email.isNull()     // email IS NULL
q.email.isNotNull()  // email IS NOT NULL

// List operators
q.id.in_([1, 2, 3])  // id IN (1, 2, 3)
q.id.notIn([1, 2, 3]) // id NOT IN (1, 2, 3)

// Range operators
q.id.between(10, 20) // id BETWEEN 10 AND 20
q.id.notBetween(10, 20) // id NOT BETWEEN 10 AND 20

// Logical operators
and([condition1, condition2])  // condition1 AND condition2
or([condition1, condition2])   // condition1 OR condition2
not(condition)                  // NOT condition
```

## SQL Expression Syntax

### Function Calls

```dart
// SQL functions
Sequelize.fn('COUNT', ['*'])           // COUNT(*)
Sequelize.fn('UPPER', [q.name])        // UPPER(name)
Sequelize.fn('CONCAT', [q.firstName, ' ', q.lastName]) // CONCAT(firstName, ' ', lastName)

// Date functions
Sequelize.fn('NOW', [])                // NOW()
Sequelize.fn('DATE', [q.createdAt])    // DATE(createdAt)

// Aggregate functions
Sequelize.fn('SUM', [q.salary])        // SUM(salary)
Sequelize.fn('AVG', [q.salary])        // AVG(salary)
Sequelize.fn('MAX', [q.salary])        // MAX(salary)
Sequelize.fn('MIN', [q.salary])        // MIN(salary)
```

### Column References

```dart
// Column references
Sequelize.col('users.id')              // users.id
Sequelize.col('posts.title')           // posts.title

// Literal values
Sequelize.literal('TRUE')              // TRUE
Sequelize.literal('1=1')               // 1=1
```

### Attribute References

```dart
// Model attributes
Sequelize.attribute('users.id')        // users.id
Sequelize.attribute('posts.user_id')    // posts.user_id
```

### Cast Expressions

```dart
// Type casting
Sequelize.cast(q.count, 'INTEGER')     // CAST(count AS INTEGER)
Sequelize.cast(q.price, 'DECIMAL')     // CAST(price AS DECIMAL)
```

## Connection Syntax

### Connection Configuration

```dart
// PostgreSQL
final sequelize = Sequelize().createInstance(
  PostgressConnection(
    url: 'postgresql://user:pass@localhost:5432/dbname',
    ssl: false,
    logging: (String sql) => print(sql),
    pool: SequelizePoolOptions(
      max: 10,        // Maximum connections
      min: 2,         // Minimum connections
      idle: 10000,    // Idle timeout (ms)
      acquire: 60000, // Acquire timeout (ms)
      evict: 1000,    // Eviction check (ms)
    ),
  ),
);

// MySQL
final sequelize = Sequelize().createInstance(
  MySqlConnection(
    host: 'localhost',
    port: 3306,
    database: 'dbname',
    username: 'user',
    password: 'pass',
    logging: (String sql) => print(sql),
  ),
);
```

### Model Registration

```dart
// Initialize with models
await sequelize.initialize(
  models: [
    Users.instance,
    Posts.instance,
    Comments.instance,
  ],
);

// Or add models individually
sequelize.addModels([Users.instance, Posts.instance]);
```

## Error Handling Syntax

### Bridge Exceptions

```dart
try {
  final result = await bridge.call('method', params);
} catch (e) {
  if (e is BridgeException) {
    // Handle bridge-specific errors
    print('Error: ${e.message}');
    if (e.code != null) {
      print('Code: ${e.code}');
    }
    if (e.stack != null) {
      print('Stack: ${e.stack}');
    }
  } else {
    rethrow;
  }
}
```

### State Errors

```dart
// Check bridge state
if (!bridge.isConnected) {
  throw Exception('Bridge not connected');
}

if (bridge.isInitializing) {
  await bridge.waitForInitialization();
}

if (bridge.isClosed) {
  throw Exception('Bridge closed');
}
```

## Code Generation Syntax

### Build Runner Commands

```bash
# Generate code once
dart run build_runner build

# Watch for changes
dart run build_runner watch

# Clean and rebuild
dart run build_runner clean
dart run build_runner build
```

### Generated File Structure

```dart
// users.model.g.dart
part of 'users.model.dart';

class $Users {
  // Generated query builder methods
  TypedColumn<Users, dynamic> get id => TypedColumn('id');
  TypedColumn<Users, String> get email => TypedColumn('email');

  Future<List<Users>> findAll(QueryBuilder<Users> Function($Users) builder) =>
      super.findAll((q) => builder(this));

  Future<Users?> findOne(QueryBuilder<Users> Function($Users) builder) =>
      super.findOne((q) => builder(this));
}

// Generated model implementation
class UsersImpl extends Users {
  @override
  ModelInterface define(String modelName, Object sequelize) {
    // Platform-specific implementation
  }

  @override
  Future<void> associateModel() async {
    // Generated association setup
    await hasMany(Post.instance, foreignKey: 'userId');
  }
}
```

## Type Definitions

### Data Types

```dart
DataType.STRING      // VARCHAR(255)
DataType.TEXT        // TEXT
DataType.INTEGER     // INTEGER
DataType.BIGINT      // BIGINT
DataType.FLOAT       // FLOAT
DataType.DOUBLE      // DOUBLE
DataType.BOOLEAN     // BOOLEAN
DataType.DATE        // DATE
DataType.JSON        // JSON
DataType.JSONB       // JSONB (PostgreSQL)
DataType.UUID        // UUID
DataType.ENUM        // ENUM
```

### Query Options

```dart
Query({
  dynamic where,
  dynamic include,
  dynamic order,
  dynamic group,
  int? limit,
  int? offset,
  QueryAttributes? attributes,
});

QueryAttributes([
  'id', 'email',  // Include specific columns
  'firstName',
]);

QueryAttributes.exclude([
  'password', 'secretKey',  // Exclude specific columns
]);
```

### Association Types

```dart
// Association methods
await hasOne(TargetModel.instance, foreignKey: 'targetId', as: 'target');
await hasMany(TargetModel.instance, foreignKey: 'targetId', as: 'targets');
await belongsTo(SourceModel.instance, foreignKey: 'sourceId', as: 'source');
await belongsToMany(TargetModel.instance,
  through: 'junction_table',
  foreignKey: 'sourceId',
  otherKey: 'targetId',
  as: 'targets',
);
```
