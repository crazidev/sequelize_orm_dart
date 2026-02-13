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

JSON column types.

```dart
// JSON column
DataType.JSON

// JSONB column (PostgreSQL only)
DataType.JSONB
```

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
| `JSON`, `JSONB` | `Map<String, dynamic>` | |
| `BLOB` | `List<int>` | Raw bytes |

## Chaining Example

You can chain multiple options for supported types to refine your column definition.

```dart
@Table()
class Product {
  // ...

  @ModelAttributes(
    type: DataType.INTEGER.UNSIGNED.ZEROFILL,
  )
  int stock;

  @ModelAttributes(
    type: DataType.DECIMAL(10,2).UNSIGNED,
  )
  double price;
}
```
