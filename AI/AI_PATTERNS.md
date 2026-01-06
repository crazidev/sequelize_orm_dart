# Sequelize Dart - Development Patterns & Syntax

## Core Patterns

### 1. Conditional Import Pattern

**Purpose**: Maintain platform separation without runtime errors

**Syntax:**

```dart
// lib/src/component/component.dart
export 'component_stub.dart'
    if (dart.library.js_interop) 'component_js.dart'
    if (dart.library.io) 'component_dart.dart';
```

**Implementation Files:**

**Stub (component_stub.dart):**

```dart
abstract class Component {
  // Define interface with UnimplementedError
  Future<void> someMethod() {
    throw UnimplementedError();
  }

  Future<dynamic> anotherMethod(dynamic param) {
    throw UnimplementedError();
  }
}
```

**JS Implementation (component_js.dart):**

```dart
import 'dart:js_interop';

class Component extends ComponentInterface {
  @override
  Future<void> someMethod() async {
    // Direct JS interop calls
    await jsObject.someMethod().toDart;
  }

  @override
  Future<dynamic> anotherMethod(dynamic param) async {
    final result = await jsObject.anotherMethod(param.jsify()).toDart;
    return result.dartify();
  }
}
```

**Dart Implementation (component_dart.dart):**

```dart
class Component extends ComponentInterface {
  @override
  Future<void> someMethod() async {
    await bridge.call('someMethod', {});
  }

  @override
  Future<dynamic> anotherMethod(dynamic param) async {
    return await bridge.call('anotherMethod', {'param': param});
  }
}
```

### 2. Extension Type Pattern (JS Interop)

**Purpose**: Type-safe JavaScript object wrappers

**Syntax:**

```dart
extension type SequelizeJS._(JSObject _) implements JSObject {
  @JS('authenticate')
  external JSPromise authenticate();

  @JS('define')
  external SequelizeModel define(
    JSString modelName,
    JSObject? attributes,
    JSObject? options,
  );
}
```

**Usage:**

```dart
// Type-safe access
final sequelize = SequelizeJS(); // Extension type
await sequelize.authenticate().toDart;

// Safe property access
final hasProperty = sequelize.hasProperty('someProperty'.toJS);
```

### 3. Bridge Communication Pattern

**Purpose**: JSON-RPC communication with Node.js bridge

**Syntax:**

```dart
// Bridge call pattern
final result = await bridge.call('methodName', {
  'param1': value1,
  'param2': value2,
});

// Error handling
try {
  final result = await bridge.call('methodName', params);
} catch (e) {
  if (e is BridgeException) {
    // Handle bridge-specific errors
    print('Bridge error: ${e.message}');
  } else {
    // Handle other errors
    rethrow;
  }
}
```

### 4. Query Builder Pattern

**Purpose**: Type-safe database queries with autocomplete

**Generated Query Class:**

```dart
class $Users {
  TypedColumn<Users, dynamic> get id => TypedColumn('id');
  TypedColumn<Users, dynamic> get email => TypedColumn('email');
  TypedColumn<Users, dynamic> get firstName => TypedColumn('firstName');

  // Comparison operators
  QueryBuilder<Users> where(dynamic condition) =>
    QueryBuilder<Users>(this).where(condition);

  // Logical operators
  QueryBuilder<Users> and(List<QueryBuilder<Users>> conditions) =>
    QueryBuilder<Users>(this).and(conditions);

  QueryBuilder<Users> or(List<QueryBuilder<Users>> conditions) =>
    QueryBuilder<Users>(this).or(conditions);
}
```

**Usage Pattern:**

```dart
// Type-safe queries with full autocomplete
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
    order: [['lastName', 'ASC'], ['firstName', 'ASC']],
    limit: 20,
    offset: 0,
  ),
);
```

### 5. Model Definition Pattern

**Purpose**: Declarative model definitions with code generation

**Annotation Syntax:**

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
  )
  dynamic email;

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

  // Required for generated model
  static $Users get instance => $Users();
}
```

### 6. Operator Pattern

**Purpose**: Type-safe database operators

**Operator Classes:**

```dart
// Comparison operators
extension TypedColumnOps<T, M> on TypedColumn<M, T> {
  QueryBuilder<M> eq(T value) => QueryBuilder<M>(null).where(column.eq(value));
  QueryBuilder<M> ne(T value) => QueryBuilder<M>(null).where(column.ne(value));
  QueryBuilder<M> gt(T value) => QueryBuilder<M>(null).where(column.gt(value));
  QueryBuilder<M> gte(T value) => QueryBuilder<M>(null).where(column.gte(value));
  QueryBuilder<M> lt(T value) => QueryBuilder<M>(null).where(column.lt(value));
  QueryBuilder<M> lte(T value) => QueryBuilder<M>(null).where(column.lte(value));
}

// String operators
extension TypedColumnStringOps<M> on TypedColumn<M, String> {
  QueryBuilder<M> like(String value) => QueryBuilder<M>(null).where(column.like(value));
  QueryBuilder<M> iLike(String value) => QueryBuilder<M>(null).where(column.iLike(value));
  QueryBuilder<M> startsWith(String value) => QueryBuilder<M>(null).where(column.startsWith(value));
  QueryBuilder<M> endsWith(String value) => QueryBuilder<M>(null).where(column.endsWith(value));
}

// Null operators
extension TypedColumnNullOps<T, M> on TypedColumn<M, T> {
  QueryBuilder<M> isNull() => QueryBuilder<M>(null).where(column.isNull());
  QueryBuilder<M> isNotNull() => QueryBuilder<M>(null).where(column.isNotNull());
}
```

### 7. Association Pattern

**Purpose**: Model relationships with automatic setup

**Association Annotations:**

```dart
@Table(tableName: 'posts')
class Post {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;

  @ModelAttributes(name: 'userId', type: DataType.INTEGER)
  dynamic userId;

  @ModelAttributes(name: 'title', type: DataType.STRING)
  dynamic title;

  static $Post get instance => $Post();
}

@Table(tableName: 'users')
class User {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;

  @ModelAttributes(name: 'name', type: DataType.STRING)
  dynamic name;

  static $User get instance => $User();
}

// Generated association setup
@override
Future<void> associateModel() async {
  // User has many posts
  await hasMany(Post.instance, foreignKey: 'userId', as: 'posts');

  // Post belongs to user
  await Post.instance.belongsTo(User.instance, foreignKey: 'userId', as: 'user');
}
```

### 8. SQL Expression Pattern

**Purpose**: Database functions and expressions

**Expression Classes:**

```dart
// SQL function builders
class SqlFn {
  final String name;
  final List<dynamic> args;

  SqlFn(this.name, this.args);

  Map<String, dynamic> toJson() => {
    '__type': 'fn',
    'fn': name,
    'args': args,
  };
}

// Usage
final result = await Users.instance.findAll(
  (q) => Query(
    where: q.createdAt.gte(Sequelize.fn('NOW', [])),
    order: [[Sequelize.fn('LOWER', [q.name]), 'ASC']],
  ),
);
```

### 9. Connection Management Pattern

**Purpose**: Database connection lifecycle

**Connection Setup:**

```dart
// Create instance
final sequelize = Sequelize().createInstance(
  PostgressConnection(
    url: 'postgresql://user:pass@localhost:5432/db',
    logging: (sql) => print(sql),
    pool: SequelizePoolOptions(
      max: 10,
      min: 2,
      idle: 10000,
      acquire: 60000,
      evict: 1000,
    ),
  ),
);

// Initialize with models
await sequelize.initialize(
  models: [Users.instance, Posts.instance],
);

// Use queries
final users = await Users.instance.findAll((q) => Query());

// Clean up
await sequelize.close();
```

### 10. Error Handling Pattern

**Purpose**: Consistent error handling across platforms

**Bridge Error Handling:**

```dart
try {
  final result = await bridge.call('someMethod', params);
} catch (e) {
  if (e is BridgeException) {
    // Detailed bridge error with context
    print('Bridge error: ${e.message}');
    if (e.code != null) {
      print('Error code: ${e.code}');
    }
    if (e.stack != null) {
      print('Stack trace: ${e.stack}');
    }
  } else {
    rethrow;
  }
}
```

**JS Interop Error Handling:**

```dart
try {
  final result = await jsObject.someMethod().toDart;
} catch (e) {
  // Handle JavaScript errors
  print('JS error: $e');
  rethrow;
}
```

## Syntax Conventions

### File Naming

- **Main export**: `component.dart`
- **Stub**: `component_stub.dart`
- **JS implementation**: `component_js.dart`
- **Dart implementation**: `component_dart.dart`

### Class Naming

- **Extension types**: `SequelizeJS`, `ModelJS`
- **Bridge classes**: `BridgeClient`, `BridgeException`
- **Generated classes**: `$Users`, `$Posts`
- **Operator classes**: `TypedColumn`, `QueryBuilder`

### Method Naming

- **Bridge methods**: `call('methodName', params)`
- **JS methods**: `jsObject.methodName().toDart`
- **Generated methods**: `findAll()`, `findOne()`, `create()`

### Variable Naming

- **JS objects**: `sequelize`, `model`
- **Bridge instances**: `bridge`, `client`
- **Query builders**: `q`, `builder`
- **Results**: `result`, `data`, `users`

## Common Pitfalls to Avoid

### 1. JS Interop Contamination

```dart
// WRONG - JS interop in Dart VM code
import 'dart:js_interop';
class SomeClass {
  void someMethod() {
    // This will crash on Dart VM
    someJsObject.callMethod('test');
  }
}

// CORRECT - Use conditional exports
export 'some_class_stub.dart'
    if (dart.library.js_interop) 'some_class_js.dart'
    if (dart.library.io) 'some_class_dart.dart';
```

### 2. Bridge State Management

```dart
// WRONG - Not checking connection
final result = await bridge.call('method', params);

// CORRECT - Check connection state
if (!bridge.isConnected) {
  throw Exception('Bridge not connected');
}
final result = await bridge.call('method', params);
```

### 3. Type Safety

```dart
// WRONG - Dynamic typing everywhere
final result = await someMethod(dynamicParam);

// CORRECT - Use generated query builders
final result = await Users.instance.findAll(
  (q) => Query(where: q.email.eq('user@example.com')),
);
```

## Development Checklist

### Adding New Features

- [ ] Define interface in stub file
- [ ] Implement JS version with extension types
- [ ] Implement Dart version with bridge calls
- [ ] Add conditional export
- [ ] Write integration tests
- [ ] Test on both platforms
- [ ] Update documentation

### Platform Testing

- [ ] Test on Dart VM (bridge)
- [ ] Test on dart2js (JS interop)
- [ ] Verify error handling
- [ ] Check performance characteristics
- [ ] Validate type safety
