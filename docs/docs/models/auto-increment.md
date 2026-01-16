---
sidebar_position: 7
---

# Auto Increment

## Basic Usage

Use the `@AutoIncrement()` annotation to create an auto-incrementing integer column.

```dart
@PrimaryKey()
@AutoIncrement()
DataType id = DataType.INTEGER;
```

This is most commonly used with the Primary Key.

## Starting Value

To set the initial auto-increment value (MySQL/MariaDB only), use the `initialAutoIncrement` option in the `@Table` annotation.

```dart
@Table(
  tableName: 'users',
  initialAutoIncrement: '1000'
)
class Users {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;
}
```
