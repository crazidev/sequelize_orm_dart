---
sidebar_position: 2
---

# Data Types

Sequelize Dart supports a wide range of data types that map to their SQL equivalents. You can access these types via the `DataType` class.

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
