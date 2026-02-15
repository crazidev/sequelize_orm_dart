---
sidebar_position: 2
---

# Data Types

Sequelize Dart supports a wide range of data types that map to their SQL equivalents. You can access these types via the `DataType` class.

:::info Bridge support
All data types on this page are fully supported in the JS bridge, including their modifiers (length, scale, UNSIGNED, ZEROFILL, BINARY, and TEXT/BLOB variants).
:::

## String Types

### `STRING`

A variable length string. Default length is 255.

```dart
// VARCHAR(255)
DataType.STRING

// VARCHAR(1234)
DataType.STRING(1234)

// VARCHAR BINARY
DataType.STRING.BINARY
```

### `CHAR`

A fixed length string. Default length is 255.

```dart
// CHAR(255)
DataType.CHAR

// CHAR(10)
DataType.CHAR(10)

// CHAR BINARY
DataType.CHAR.BINARY
```

### `TEXT`

An unlimited length text column.

```dart
// TEXT
DataType.TEXT

// TINYTEXT
DataType.TEXT.tiny

// MEDIUMTEXT
DataType.TEXT.medium

// LONGTEXT
DataType.TEXT.long
```

## Numeric Types

### Integers

Sequelize Dart supports several integer types.

```dart
// INTEGER
DataType.INTEGER

// SMALLINT
DataType.SMALLINT

// BIGINT
DataType.BIGINT

// TINYINT
DataType.TINYINT

// MEDIUMINT
DataType.MEDIUMINT
```

#### Integer Options

You can specify length, zerofill, and unsigned attributes for integer types.

```dart
// INTEGER(11)
DataType.INTEGER(11)

// INTEGER UNSIGNED
DataType.INTEGER.UNSIGNED

// INTEGER UNSIGNED ZEROFILL
DataType.INTEGER.UNSIGNED.ZEROFILL
```

### BIGINT and `SequelizeBigInt`

SQL `BIGINT` can hold values up to 2^63 - 1, but JavaScript numbers lose precision beyond 2^53. Because of this, Sequelize (Node.js) always returns BIGINT values as **strings**. Sequelize Dart follows this standard with a dedicated `SequelizeBigInt` type that wraps the string value while providing typed access.

#### Dart type mapping

| SQL Type | Dart Type |
|---|---|
| `TINYINT`, `SMALLINT`, `MEDIUMINT`, `INTEGER` | `int` |
| `BIGINT` | `SequelizeBigInt` |

#### Defining a BIGINT column

```dart
@Table()
abstract class Users {
  @ColumnName('phone_number')
  DataType phoneNumber = DataType.BIGINT;
}
```

This generates a `SequelizeBigInt?` field in the model:

```dart
// Generated code
final SequelizeBigInt? phoneNumber;
```

#### Creating records

```dart
// From a string (most common)
await Db.users.create(CreateUsers(
  phoneNumber: SequelizeBigInt('9223372036854775807'),
));

// From an int
await Db.users.create(CreateUsers(
  phoneNumber: SequelizeBigInt.fromInt(42),
));

// From a BigInt
await Db.users.create(CreateUsers(
  phoneNumber: SequelizeBigInt.fromBigInt(BigInt.parse('9223372036854775807')),
));
```

#### Reading values

```dart
final user = await Db.users.findOne();

// The raw string value
user?.phoneNumber?.value;          // "9223372036854775807"

// Convert to Dart BigInt for arithmetic
user?.phoneNumber?.toBigInt();     // 9223372036854775807

// Convert to int (only safe for small values)
user?.phoneNumber?.toInt();        // throws FormatException if too large
```

#### JSON serialization

`toJson()` always returns the string representation, ensuring no precision loss:

```dart
user?.toJson();
// { "phone_number": "9223372036854775807", ... }
```

:::tip Why not plain String?
Using `SequelizeBigInt` instead of `String` makes it immediately clear which fields are bigint values in your model. The compiler prevents accidentally mixing bigint fields with regular strings, and conversion helpers (`.toBigInt()`, `.toInt()`) are always at hand.
:::

### Decimals & Floats

For floating-point and fixed-point numbers.

```dart
// FLOAT
DataType.FLOAT

// DOUBLE
DataType.DOUBLE

// DECIMAL
DataType.DECIMAL
```

#### Decimal Options

You can specify precision and scale for `DECIMAL`.

```dart
// DECIMAL(10, 2)
DataType.DECIMAL(10, 2)

// DECIMAL(10, 2) UNSIGNED
DataType.DECIMAL(10, 2).UNSIGNED
```

## Date & Time Types

```dart
// DATETIME for mysql / sqlite, TIMESTAMP WITH TIME ZONE for postgres
DataType.DATE

// DATE without time
DataType.DATEONLY
```

## Other Types

### `BOOLEAN`

```dart
// TINYINT(1) or BOOLEAN
DataType.BOOLEAN
```

### `BLOB`

Binary Large Object.

```dart
// BLOB
DataType.BLOB

// TINYBLOB
DataType.BLOB.tiny

// MEDIUMBLOB
DataType.BLOB.medium

// LONGBLOB
DataType.BLOB.long
```

### `UUID`

Universally Unique Identifier.

```dart
// UUID
DataType.UUID
```

### `JSON` & `JSONB`

JSON column types. By default they map to `Map<String, dynamic>`, but you can specify a custom Dart type with the `type:` parameter.

```dart
// Default: Map<String, dynamic>
DataType.JSON
DataType.JSONB

// Custom Dart types
DataType.JSONB(type: List<String>)
DataType.JSONB(type: List<int>)
DataType.JSONB(type: List<double>)
DataType.JSONB(type: List<bool>)
DataType.JSONB(type: List<dynamic>)
DataType.JSONB(type: List<Map<String, dynamic>>)
DataType.JSON(type: Map<String, String>)
DataType.JSON(type: Map<String, int>)
```

#### Defining JSON columns with custom types

```dart
@Table()
abstract class Users {
  DataType tags = DataType.JSONB(type: List<String>);
  DataType scores = DataType.JSONB(type: List<int>);
  DataType metadata = DataType.JSONB; // default Map<String, dynamic>
}
```

This generates correctly typed fields and parsers:

```dart
// Generated code
final List<String>? tags;     // parsed with parseJsonList<String>
final List<int>? scores;      // parsed with parseJsonList<int>
final Map<String, dynamic>? metadata; // parsed with parseJsonMap<dynamic>
```

#### Creating records

```dart
await Db.users.create(CreateUsers(
  tags: ['dart', 'flutter', 'sequelize'],
  scores: [100, 200, 300],
  metadata: {'role': 'admin', 'level': 5},
));
```

#### Reading values

The generated `fromJson` automatically handles JSON strings returned by the bridge (via `jsonDecode`), so you always get the correct Dart type:

```dart
final user = await Db.users.findOne();

user?.tags;     // List<String>?
user?.scores;   // List<int>?
user?.metadata; // Map<String, dynamic>?
```

#### Supported `type:` values

**Array JSON:**

```dart
DataType.JSONB(type: List<String>)
DataType.JSONB(type: List<int>)
DataType.JSONB(type: List<double>)
DataType.JSONB(type: List<bool>)
DataType.JSONB(type: List<dynamic>)
DataType.JSONB(type: List<Map<String, dynamic>>)
```

**Object JSON:**

```dart
DataType.JSONB                                    // default: Map<String, dynamic>
DataType.JSONB(type: Map<String, String>)
DataType.JSONB(type: Map<String, int>)
DataType.JSONB(type: Map<String, double>)
DataType.JSONB(type: Map<String, bool>)
```

:::tip JSON vs JSONB
`JSONB` stores data in a binary format and supports indexing in PostgreSQL. Use `JSONB` for PostgreSQL and `JSON` for MySQL / other databases.

By default, Sequelize normalizes JSON types automatically (`normalizeJsonTypes: true`). This means you can write `DataType.JSON` or `DataType.JSONB` and Sequelize will convert it to the correct type for the connected database:
- **PostgreSQL**: `JSON` is automatically promoted to `JSONB` (required for full JSON querying)
- **MySQL / MariaDB**: `JSONB` is automatically downgraded to `JSON` (the only supported type)

To disable this behavior, set `normalizeJsonTypes: false` when creating the Sequelize instance:

```dart
final sequelize = Sequelize().createInstance(
  connection: SequelizeConnection.postgres(url: '...'),
  normalizeJsonTypes: false, // opt out of automatic type normalization
);
```
:::

:::tip Bridge compatibility
The bridge may return JSON columns as raw strings. The generated parsers automatically call `jsonDecode` when they receive a string, so no manual handling is needed.
:::

For a complete guide on querying JSON columns — including `.key()`, `.at()`, `.contains()`, and more — see **[JSON Querying](../querying/json)**.

## SQL to Dart Type Mapping

The following table shows how each SQL data type maps to a Dart type in generated models:

| SQL Type | Dart Type | Notes |
|---|---|---|
| `TINYINT`, `SMALLINT`, `MEDIUMINT`, `INTEGER` | `int` | |
| `BIGINT` | `SequelizeBigInt` | String-backed to prevent precision loss |
| `FLOAT`, `DOUBLE`, `DECIMAL` | `double` | |
| `BOOLEAN` | `bool` | Also parses `1`/`0` from `int` |
| `DATE`, `DATEONLY` | `DateTime` | |
| `STRING`, `CHAR`, `TEXT`, `UUID` | `String` | |
| `JSON`, `JSONB` | `Map<String, dynamic>` | Customizable via `type:` parameter |
| `BLOB` | `List<int>` | Raw bytes |

## Chaining Example

You can chain multiple options for supported types to refine your column definition.

```dart
@Table()
abstract class Product {
  // INTEGER UNSIGNED ZEROFILL
  DataType stock = DataType.INTEGER.UNSIGNED.ZEROFILL;

  // DECIMAL(10,2) UNSIGNED
  DataType price = DataType.DECIMAL(10, 2).UNSIGNED;
}
```
