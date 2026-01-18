# sequelize_dart_annotations

Platform-independent annotations package for Sequelize Dart. This package provides all the annotations and enums used for model definition and code generation.

## Installation

```yaml
dependencies:
  sequelize_dart_annotations:
    path: ../sequelize_dart_annotations
```

## Table Annotations

### `@Table`

Marks a class as a database table model.

```dart
@Table(
  tableName: 'users',
  underscored: true,
  timestamps: true,
)
class User {
  // ...
}
```

**Key Parameters:**

- `tableName` (required): The name of the database table
- `underscored`: If true, column names will be snake_cased (default: `false`)
- `timestamps`: Adds `createdAt` and `updatedAt` timestamps (default: `true`)
- `paranoid`: Enables soft deletes with `deletedAt` timestamp (default: `false`)
- `freezeTableName`: Prevents pluralization of table name (default: `false`)
- `schema`: Database schema name (PostgreSQL)
- `modelName`: Custom model name

## Field Annotations

### `@PrimaryKey`

Marks a field as the primary key.

```dart
@PrimaryKey()
DataType id = DataType.INTEGER;
```

### `@AutoIncrement`

Marks a field as auto-incrementing.

```dart
@AutoIncrement()
DataType id = DataType.INTEGER;
```

### `@NotNull`

Marks a field as NOT NULL in the database.

```dart
@NotNull()
DataType email = DataType.STRING;
```

### `@AllowNull`

Explicitly allows NULL values (default behavior).

```dart
@AllowNull()
DataType middleName = DataType.STRING;
```

### `@ColumnName`

Specifies a custom column name in the database.

```dart
@ColumnName('email_address')
DataType email = DataType.STRING;
```

### `@Default`

Sets a default value for the column.

```dart
// Literal default value
@Default('active')
DataType status = DataType.STRING;

// UUID default
@Default.uniqid()
DataType uuid = DataType.UUID;

// Current timestamp
@Default.now()
DataType createdAt = DataType.DATE;

// SQL function
@Default.fn('NOW()')
DataType timestamp = DataType.DATE;
```

### `@Unique`

Marks a column as unique.

```dart
// Simple unique constraint
@Unique()
DataType email = DataType.STRING;

// Named unique constraint (for composite unique indexes)
@Unique(UniqueOption(name: 'email_username_unique'))
DataType email = DataType.STRING;
```

### `@Index`

Creates an index on the column.

```dart
// Simple index
@Index()
DataType username = DataType.STRING;

// Named index (for composite indexes)
@Index(IndexOption.named('username_email_idx'))
DataType username = DataType.STRING;
```

### `@Comment`

Adds a comment to the column (MySQL, PostgreSQL).

```dart
@Comment('User email address')
DataType email = DataType.STRING;
```

## Column Definition

You can also use `ColumnDefinition` class in `@ModelAttributes` for complete control:

```dart
@ModelAttributes(
  name: 'email',
  type: DataType.STRING,
  allowNull: false,
  unique: true,
  validate: ValidateOption(
    isEmail: IsEmail('Email must be valid'),
    notEmpty: NotEmpty('Email cannot be empty'),
  ),
)
DataType email = DataType.STRING;
```

## Validators

Validators provide runtime validation for your data. They are executed when saving model instances.

### Boolean Validators

```dart
@IsEmail('Invalid email format')
DataType email = DataType.STRING;

@IsUrl('Invalid URL format')
DataType website = DataType.STRING;

@IsIP('Invalid IP address')
DataType ipAddress = DataType.STRING;

@IsAlpha('Only letters allowed')
DataType name = DataType.STRING;

@IsAlphanumeric('Only alphanumeric characters allowed')
DataType username = DataType.STRING;

@IsNumeric('Only numbers allowed')
DataType phoneNumber = DataType.STRING;

@IsInt('Must be an integer')
DataType age = DataType.INTEGER;

@IsFloat('Must be a float')
DataType price = DataType.FLOAT;

@IsLowercase('Must be lowercase')
DataType code = DataType.STRING;

@IsUppercase('Must be uppercase')
DataType code = DataType.STRING;

@NotEmpty('Cannot be empty')
DataType title = DataType.STRING;

@IsArray('Must be an array')
DataType tags = DataType.JSON;

@IsCreditCard('Invalid credit card number')
DataType cardNumber = DataType.STRING;

@IsDate('Must be a valid date')
DataType birthDate = DataType.DATE;
```

### Pattern Validators

```dart
// Simple pattern
@Is('^[a-z]+$', 'Only lowercase letters allowed')
DataType code = DataType.STRING;

// Pattern with flags
@Is.withFlags('^[a-z]+$', 'i', 'Only letters allowed')
DataType code = DataType.STRING;

// Negated pattern
@Not('[0-9]', 'Cannot contain numbers')
DataType text = DataType.STRING;
```

### String Validators

```dart
@Equals('active', 'Status must be active')
DataType status = DataType.STRING;

@Contains('@', 'Must contain @')
DataType text = DataType.STRING;

@IsAfter('2020-01-01', 'Date must be after 2020')
DataType date = DataType.DATE;

@IsBefore('2030-12-31', 'Date must be before 2030')
DataType date = DataType.DATE;
```

### Number Validators

```dart
@Max(100, 'Value must be <= 100')
DataType score = DataType.INTEGER;

@Min(0, 'Value must be >= 0')
DataType quantity = DataType.INTEGER;
```

### Range Validators

```dart
@Len(5, 50, 'Length must be between 5 and 50')
DataType description = DataType.STRING;
```

### List Validators

```dart
@IsIn(['active', 'inactive', 'pending'], 'Invalid status')
DataType status = DataType.STRING;

@NotIn(['banned', 'deleted'], 'Invalid status')
DataType status = DataType.STRING;

@NotContains(['bad', 'spam'], 'Cannot contain forbidden words')
DataType content = DataType.STRING;
```

### UUID Validators

```dart
@IsUUID(4, 'Must be a valid UUID v4')
DataType uuid = DataType.UUID;
```

## Using Validate Namespace

You can also use the `Validate` namespace for all validators:

```dart
@Validate.IsEmail('Invalid email')
DataType email = DataType.STRING;

@Validate.Max(100, 'Too large')
DataType score = DataType.INTEGER;

@Validate.Len(5, 50, 'Invalid length')
DataType username = DataType.STRING;
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
- `TIME` - TIME
- `UUID` - UUID
- `JSON` - JSON
- `JSONB` - JSONB (PostgreSQL only)
- `BLOB` - BLOB/BINARY
- `GEOMETRY` - GEOMETRY (PostgreSQL)

## Complete Example

```dart
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

part 'user.model.g.dart';

@Table(
  tableName: 'users',
  underscored: true,
  timestamps: true,
)
class User {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @NotNull()
  @Unique()
  @IsEmail('Invalid email format')
  @Len(5, 255)
  DataType email = DataType.STRING;

  @NotNull()
  @Len(3, 50)
  @IsAlpha('Only letters allowed')
  DataType firstName = DataType.STRING;

  @ColumnName('last_name')
  @NotNull()
  DataType lastName = DataType.STRING;

  @Default('active')
  @IsIn(['active', 'inactive', 'pending'])
  DataType status = DataType.STRING;

  @Default.now()
  DataType createdAt = DataType.DATE;

  @Default.now()
  DataType updatedAt = DataType.DATE;

  static $User get instance => $User();
}
```

## See Also

- [sequelize_dart](../sequelize_dart/README.md) - Main package
- [sequelize_dart_generator](../sequelize_dart_generator/README.md) - Code generator
