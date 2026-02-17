Models in Sequelize Dart are regular Dart classes annotated with `@Table` and
column annotations. The code generator produces type-safe model classes, query
builders, DTOs, and include helpers from your annotated classes.

## Defining a Model

```dart
import 'package:sequelize_orm/sequelize_orm.dart';

part 'users.model.g.dart';

@Table(tableName: 'users', underscored: true, timestamps: true, paranoid: true)
class Users {
  @PrimaryKey()
  @AutoIncrement()
  @NotNull()
  DataType id = DataType.INTEGER;

  @NotNull()
  @IsEmail()
  DataType email = DataType.STRING;

  @ColumnName('first_name')
  @NotNull()
  DataType firstName = DataType.STRING;

  @ColumnName('last_name')
  DataType lastName = DataType.STRING;

  @AllowNull()
  DataType bio = DataType.TEXT;

  @Default(true)
  DataType isActive = DataType.BOOLEAN;

  static UsersModel get model => UsersModel();
}
```

## Table Options

| Option             | Type     | Description                                              |
| ------------------ | -------- | -------------------------------------------------------- |
| `tableName`        | `String` | The name of the table in the database                    |
| `underscored`      | `bool`   | Use snake_case column names. Default: `false`            |
| `timestamps`       | `bool`   | Add `createdAt` / `updatedAt` columns. Default: `true`  |
| `paranoid`         | `bool`   | Soft deletes via `deletedAt`. Requires timestamps        |
| `freezeTableName`  | `bool`   | Prevent automatic pluralisation                          |
| `schema`           | `String` | Database schema (e.g. `public`)                          |

## Column Annotations

| Annotation            | Description                              |
| --------------------- | ---------------------------------------- |
| `@PrimaryKey()`       | Marks the column as the primary key      |
| `@AutoIncrement()`    | Column auto-increments                   |
| `@ColumnName('name')` | Set the database column name explicitly  |
| `@NotNull()`          | Adds a NOT NULL constraint               |
| `@AllowNull()`        | Explicitly allows NULL                   |
| `@Default(value)`     | Sets a default value                     |
| `@Unique()`           | Adds a unique constraint                 |
| `@Index()`            | Creates an index on the column           |
| `@Comment('text')`    | Adds a comment to the column             |

## Data Types

```dart
DataType.INTEGER        // int
DataType.BIGINT         // SequelizeBigInt
DataType.FLOAT          // double
DataType.DOUBLE         // double
DataType.DECIMAL        // double
DataType.STRING         // String (VARCHAR)
DataType.CHAR           // String (CHAR)
DataType.TEXT           // String (TEXT)
DataType.BOOLEAN        // bool
DataType.DATE           // DateTime
DataType.DATEONLY       // DateTime (date only)
DataType.UUID           // String
DataType.JSON           // Map<String, dynamic>
DataType.JSONB          // Map<String, dynamic> (PostgreSQL)
DataType.BLOB           // dynamic
```

## Validation Annotations

```dart
@IsEmail()              // Validates email format
@IsUrl()                // Validates URL format
@Len(min: 2, max: 50)  // String length constraint
@Min(0)                 // Minimum numeric value
@Max(100)               // Maximum numeric value
@IsUUID(4)              // UUID version check
@IsIn(['a', 'b', 'c']) // Whitelist values
```

## Generated Output

After running `dart run build_runner build`, the generator produces:

- **`UsersModel`** — static query methods (`findAll`, `findOne`, `create`, etc.)
- **`UsersValues`** — instance data with methods (`save`, `reload`, `destroy`)
- **`CreateUsers`** / **`UpdateUsers`** — type-safe DTOs
- **`UsersColumns`** — column references for where clauses
- **`UsersQuery`** — extends columns with association references
- **`UsersIncludeHelper`** — type-safe eager loading builder
