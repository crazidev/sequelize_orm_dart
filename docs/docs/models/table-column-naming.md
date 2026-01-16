---
sidebar_position: 3
---

# Table & Column Naming

## Table Naming

The table name is specified in the `@Table` annotation:

```dart
@Table(tableName: 'users')
class Users { }
```

## Column Naming

### Automatic Naming (with underscored)

When `underscored: true`, Dart property names are automatically converted to snake_case:

```dart
@Table(tableName: 'users', underscored: true)
class Users {
  DataType firstName = DataType.STRING;    // Maps to 'first_name'
  DataType lastName = DataType.STRING;     // Maps to 'last_name'
  DataType emailAddress = DataType.STRING; // Maps to 'email_address'
}
```

### Explicit Column Names

You can override the column name explicitly:

```dart
@ColumnName('first_name')
DataType firstName = DataType.STRING;
```

### Without Underscored

If `underscored: false`, column names match property names exactly:

```dart
@Table(tableName: 'users', underscored: false)
class Users {
  DataType firstName = DataType.STRING; // Maps to 'firstName'
  DataType lastName = DataType.STRING;  // Maps to 'lastName'
}
```
