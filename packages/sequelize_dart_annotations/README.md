# sequelize_dart_annotations

Platform-independent annotations package for Sequelize Dart. This package provides the annotations and enums used for code generation and model definition.

## Installation

```yaml
dependencies:
  sequelize_dart_annotations:
    path: ../sequelize_dart_annotations
```

## Annotations

### `@Table`

Marks a class as a database table model.

```dart
@Table(tableName: 'users')
class Users {
  // ...
}
```

**Parameters:**

- `tableName` (required): The name of the database table

### `@ModelAttributes`

Defines a database column attribute.

```dart
@ModelAttributes(
  name: 'id',
  type: DataType.INTEGER,
  primaryKey: true,
  autoIncrement: true,
  allowNull: true,
  unique: false,
  defaultValue: null,
  references: null,
)
dynamic id;
```

**Parameters:**

- `name` (required): The column name in the database
- `type` (required): The data type (from `DataType` enum)
- `primaryKey` (optional): Whether this is a primary key (default: `false`)
- `autoIncrement` (optional): Whether this column auto-increments (default: `false`)
- `allowNull` (optional): Whether null values are allowed (default: `true`)
- `unique` (optional): Whether this column is unique (default: `false`)
- `defaultValue` (optional): Default value for the column
- `references` (optional): Foreign key reference (using `ForeignKey`)

### Foreign Keys

```dart
@ModelAttributes(
  name: 'userId',
  type: DataType.INTEGER,
  references: ForeignKey(
    model: Users,
    key: 'id',
  ),
)
dynamic userId;
```

## Data Types

Available data types from the `DataType` enum:

- `STRING` - VARCHAR/TEXT
- `TEXT` - TEXT/LONGTEXT
- `INTEGER` - INT
- `BIGINT` - BIGINT
- `FLOAT` - FLOAT
- `DOUBLE` - DOUBLE
- `DECIMAL` - DECIMAL
- `BOOLEAN` - BOOLEAN
- `DATE` - DATETIME/TIMESTAMP
- `DATEONLY` - DATE
- `UUID` - UUID
- `JSON` - JSON
- `JSONB` - JSONB (PostgreSQL)

## Example

```dart
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

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
    allowNull: false,
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

## See Also

- [sequelize_dart](../sequelize_dart/README.md) - Main package
- [sequelize_dart_generator](../sequelize_dart_generator/README.md) - Code generator
