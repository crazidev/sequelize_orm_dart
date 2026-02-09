---
sidebar_position: 1
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# Defining Models

Models in Sequelize Dart are regular Dart classes annotated with `@Table` and various column annotations. Here's the basic structure:

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_annotations/sequelize_orm_annotations.dart'; // Optional if exported by main package

part 'users.model.g.dart';

// highlight-next-line
@Table(tableName: 'users')
class User {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @ColumnName('first_name')
  DataType firstName = DataType.STRING;

  @ColumnName('last_name')
  DataType lastName = DataType.STRING;

  // Use @AllowNull or @NotNull
  @AllowNull()
  DataType bio = DataType.TEXT;

  static UserModel get model => UserModel();
}
```

## Table Configuration

The `@Table` annotation allows you to configure the table definition.

### Basic Options

| Option        | Type      | Description                                                   |
| ------------- | --------- | ------------------------------------------------------------- |
| `tableName`   | `String`  | The name of the table in the database.                        |
| `underscored` | `bool`    | If `true`, columns will use snake_case by default.            |
| `timestamps`  | `bool`    | Adds `createdAt` and `updatedAt` timestamps. Default: `true`. |
| `schema`      | `String?` | The database schema (e.g. `public`).                          |

### All Options

<details>
<summary>Click to see all @Table options</summary>

| Option            | Type     | Description                                                  |
| ----------------- | -------- | ------------------------------------------------------------ |
| `tableName`       | `String` | The table name (required).                                   |
| `omitNull`        | `bool?`  | Don't persist null values. Default `false`.                  |
| `noPrimaryKey`    | `bool?`  | Disable automatic primary key. Default `false`.              |
| `timestamps`      | `bool?`  | Enable timestamps. Default `false`.                          |
| `paranoid`        | `bool?`  | Soft deletes (requires timestamps). Default `false`.         |
| `underscored`     | `bool?`  | Snake_case columns. Default `false`.                         |
| `hasTrigger`      | `bool?`  | Indicates table has trigger. Default `false`.                |
| `freezeTableName` | `bool?`  | Stop Sequelize from pluralizing table name. Default `false`. |

| `name` | `ModelNameOption?` | Singular/Plural model names. |
| `modelName` | `String?` | The name of the model. |
| `updatedAt` | `TimestampOption?` | Custom name or disable `updatedAt`. |
| `deletedAt` | `TimestampOption?` | Custom name or disable `deletedAt`. |
| `schema` | `String?` | Database schema. |
| `schemaDelimiter` | `String?` | Delimiter for schema. |
| `engine` | `String?` | Storage engine (MySQL/MariaDB). |
| `charset` | `String?` | Charset (MySQL/MariaDB). |
| `comment` | `String?` | Table comment. |
| `collate` | `String?` | Table collation. |
| `initialAutoIncrement` | `String?` | Initial auto-increment value (MySQL). |
| `version` | `VersionOption?` | Optimistic locking version. |

</details>

## Column Annotations

Define your table columns using field annotations on `DataType` fields.

| Annotation            | Description                              |
| --------------------- | ---------------------------------------- |
| `@PrimaryKey()`       | Marks the column as the primary key.     |
| `@AutoIncrement()`    | Column auto-increments.                  |
| `@ColumnName('name')` | Explicitly set the database column name. |
| `@NotNull()`          | Adds a `NOT NULL` constraint.            |
| `@AllowNull()`        | Explicitly allows `NULL`.                |
| `@Default(value)`     | Sets a default value.                    |
| `@Unique()`           | Adds a unique constraint.                |
| `@Index()`            | Creates an index on the column.          |
| `@Comment('text')`    | Adds a comment to the column.            |
