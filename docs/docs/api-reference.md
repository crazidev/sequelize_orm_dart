# API Reference

Complete API reference for Sequelize Dart.

## Sequelize

The main Sequelize class for creating database connections.

### Methods

#### `createInstance(SequelizeCoreOptions)`

Creates and configures a Sequelize instance.

**Parameters:**
- `options` - Connection options (PostgressConnection, MysqlConnection, or MariadbConnection)

**Returns:** `Sequelize` instance

**Example:**
```dart
var sequelize = Sequelize().createInstance(
  PostgressConnection(
    url: 'postgresql://user:password@localhost:5432/dbname',
    ssl: false,
  ),
);
```

#### `authenticate()`

Verifies the database connection.

**Returns:** `Future<void>`

**Throws:** `BridgeException` if connection fails

**Example:**
```dart
await sequelize.authenticate();
print('Connected!');
```

#### `addModels(List<Model> models)`

Registers models with the Sequelize instance.

**Parameters:**
- `models` - List of model instances (e.g., `[Users.instance]`)

**Example:**
```dart
sequelize.addModels([
  Users.instance,
  Posts.instance,
]);
```

#### `close()`

Closes the database connection and shuts down the bridge process.

**Returns:** `Future<void>`

**Example:**
```dart
await sequelize.close();
```

## Model

Base model class. Generated models extend this class.

### Methods

#### `findAll([Query? query])`

Finds all records matching the query.

**Parameters:**
- `query` - Optional query options (Query object or typed query callback)

**Returns:** `Future<List<T>>` where T is the model's value type (e.g., `$UsersValues`)

**Example:**
```dart
// Without query
var allUsers = await Users.instance.findAll();

// With query
var users = await Users.instance.findAll(
  Query(where: equal('email', 'user@example.com')),
);

// With typed query
var users = await Users.instance.findAll(
  (q) => Query(where: q.id.gt(1)),
);
```

#### `findOne([Query? query])`

Finds one record matching the query.

**Parameters:**
- `query` - Optional query options (Query object or typed query callback)

**Returns:** `Future<T?>` where T is the model's value type (null if not found)

**Example:**
```dart
var user = await Users.instance.findOne(
  Query(where: equal('id', 1)),
);
```

#### `create(Map<String, dynamic> data)`

Creates a new record.

**Parameters:**
- `data` - Map of field names to values

**Returns:** `Future<T>` where T is the model's value type

**Example:**
```dart
var newUser = await Users.instance.create({
  'email': 'user@example.com',
  'firstName': 'John',
  'lastName': 'Doe',
});
```

## Query

Query options class for building queries.

### Properties

- `where` - `QueryOperator?` - Where conditions
- `order` - `List<List<String>>?` - Order by clauses `[['column', 'ASC|DESC']]`
- `limit` - `int?` - Maximum number of records
- `offset` - `int?` - Number of records to skip
- `include` - `List<dynamic>?` - Associations (future feature)

### Constructor

```dart
Query({
  QueryOperator? where,
  List<List<String>>? order,
  int? limit,
  int? offset,
  List<dynamic>? include,
})
```

### Example

```dart
var query = Query(
  where: equal('email', 'user@example.com'),
  order: [['id', 'DESC']],
  limit: 10,
  offset: 0,
);
```

## Connection Options

### PostgressConnection

PostgreSQL connection options.

**Properties:**
- `url` (required) - Connection URL string
- `ssl` - Enable SSL (default: `false`)
- `logging` - Logging function `(String sql) => void`
- `pool` - Connection pool options (`SequelizePoolOptions`)

**Example:**
```dart
PostgressConnection(
  url: 'postgresql://user:password@localhost:5432/dbname',
  ssl: false,
  logging: (String sql) => print(sql),
  pool: SequelizePoolOptions(max: 10, min: 2),
)
```

### MysqlConnection

MySQL connection options.

**Properties:** Same as PostgressConnection

**Example:**
```dart
MysqlConnection(
  url: 'mysql://user:password@localhost:3306/dbname',
  ssl: false,
)
```

### MariadbConnection

MariaDB connection options.

**Properties:** Same as PostgressConnection

**Example:**
```dart
MariadbConnection(
  url: 'mariadb://user:password@localhost:3306/dbname',
  ssl: false,
)
```

### SequelizePoolOptions

Connection pool configuration.

**Properties:**
- `max` - Maximum connections in pool
- `min` - Minimum connections in pool
- `idle` - Idle timeout in milliseconds
- `acquire` - Maximum time to get connection (ms)
- `evict` - Check for idle connections (ms)

**Example:**
```dart
SequelizePoolOptions(
  max: 10,
  min: 2,
  idle: 10000,
  acquire: 60000,
  evict: 1000,
)
```

## Operators

### Logical Operators

#### `and(List<QueryOperator> values)`

Creates an AND condition.

**Returns:** `LogicalOperator`

**Example:**
```dart
where: and([
  equal('email', 'user@example.com'),
  equal('firstName', 'John'),
])
```

#### `or(List<QueryOperator> values)`

Creates an OR condition.

**Returns:** `LogicalOperator`

**Example:**
```dart
where: or([
  equal('id', 1),
  equal('id', 2),
])
```

#### `not(List<QueryOperator> values)`

Creates a NOT condition.

**Returns:** `LogicalOperator`

**Example:**
```dart
where: not([
  equal('email', 'admin@example.com'),
])
```

### Comparison Operators

#### `equal(String column, dynamic value)`

Creates an equality condition.

**Returns:** `ComparisonOperator`

**Example:**
```dart
where: equal('id', 1)
```

#### `notEqual(String column, dynamic value)`

Creates a not-equal condition.

**Returns:** `ComparisonOperator`

**Example:**
```dart
where: notEqual('id', 1)
```

#### `ComparisonOperator`

Generic comparison operator for advanced conditions.

**Constructor:**
```dart
ComparisonOperator({
  required dynamic column,
  required dynamic value,
})
```

**Supported value operators:**
- `$gt` - Greater than
- `$gte` - Greater than or equal
- `$lt` - Less than
- `$lte` - Less than or equal
- `$like` - LIKE pattern
- `$ilike` - Case-insensitive LIKE (PostgreSQL)
- `$in` - IN list
- `$notIn` - NOT IN list
- `$between` - BETWEEN range
- `$notBetween` - NOT BETWEEN range
- `$is` - IS NULL
- `$not` - IS NOT NULL
- `$regexp` - Regular expression (PostgreSQL)
- `$iRegexp` - Case-insensitive regex (PostgreSQL)

**Example:**
```dart
where: ComparisonOperator(
  column: 'age',
  value: {'$gt': 18, '$lt': 65},
)
```

## Typed Query Builder

When using typed queries, the query builder (`q`) provides typed access to model columns.

### Column Access

Access columns through the query builder:

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.email.eq('user@example.com'),
  ),
);
```

### Typed Column Methods

Typed columns support the following methods:

- `eq(value)` - Equal
- `ne(value)` - Not equal
- `gt(value)` - Greater than
- `gte(value)` - Greater than or equal
- `lt(value)` - Less than
- `lte(value)` - Less than or equal
- `isNull()` - IS NULL
- `isNotNull()` - IS NOT NULL
- `like(pattern)` - LIKE
- `notLike(pattern)` - NOT LIKE
- `startsWith(prefix)` - Starts with
- `endsWith(suffix)` - Ends with
- `substring(text)` - Contains
- `iLike(pattern)` - Case-insensitive LIKE (PostgreSQL)
- `notILike(pattern)` - Case-insensitive NOT LIKE (PostgreSQL)
- `in_(list)` - IN list
- `notIn(list)` - NOT IN list
- `between(min, max)` - BETWEEN
- `notBetween(min, max)` - NOT BETWEEN
- `and(condition)` - AND
- `or(condition)` - OR

**Example:**
```dart
where: q.id.gt(1).and(q.email.like('%@example.com'))
```

## Data Types

Available data types from `DataType` enum:

- `INTEGER` - Integer numbers
- `STRING` - Text strings
- `TEXT` - Long text
- `BOOLEAN` - Boolean values
- `DATE` - Date and time
- `DECIMAL` - Decimal numbers
- `FLOAT` - Floating point numbers
- `DOUBLE` - Double precision floats
- `BIGINT` - Large integers
- `UUID` - UUID strings
- `JSON` - JSON data
- `JSONB` - JSONB (PostgreSQL only)
- `BLOB` - Binary data
- `ENUM` - Enumeration values

## Annotations

### @Table

Table annotation for model classes.

**Parameters:**
- `tableName` (required) - Database table name
- `underscored` - Use snake_case (default: `true`)
- `timestamps` - Add createdAt/updatedAt (default: `true`)

**Example:**
```dart
@Table(tableName: 'users', underscored: true, timestamps: true)
class Users {
  // ...
}
```

### @ModelAttributes

Model attribute annotation.

**Parameters:**
- `name` (required) - Column name
- `type` (required) - Data type
- `primaryKey` - Primary key flag
- `autoIncrement` - Auto-increment flag
- `unique` - Unique constraint
- `notNull` - NOT NULL constraint
- `defaultValue` - Default value

**Example:**
```dart
@ModelAttributes(
  name: 'id',
  type: DataType.INTEGER,
  primaryKey: true,
  autoIncrement: true,
)
dynamic id;
```

## Exceptions

### BridgeException

Exception thrown by the bridge process (Dart server only).

**Properties:**
- `message` - Error message
- `originalError` - Original error from Sequelize.js
- `sql` - SQL query that caused the error (if available)
- `code` - Error code

**Example:**
```dart
try {
  await sequelize.authenticate();
} on BridgeException catch (e) {
  print('Error: ${e.message}');
  print('SQL: ${e.sql}');
}
```

## Next Steps

- See [Examples](./examples.md) for usage examples
- Learn about [Models](./models.md) for model definitions
- Explore [Querying](./querying.md) for query building
