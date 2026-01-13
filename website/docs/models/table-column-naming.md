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
  dynamic firstName;   // Maps to 'first_name'
  dynamic lastName;    // Maps to 'last_name'
  dynamic emailAddress; // Maps to 'email_address'
}
```

### Explicit Column Names

You can override the column name explicitly:

```dart
@ModelAttributes(
  name: 'first_name',  // Explicit column name
  type: DataType.STRING,
)
dynamic firstName;
```

### Without Underscored

If `underscored: false`, column names match property names exactly:

```dart
@Table(tableName: 'users', underscored: false)
class Users {
  dynamic firstName;   // Maps to 'firstName'
  dynamic lastName;    // Maps to 'lastName'
}
```
