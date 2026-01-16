---
sidebar_position: 6
---

# Primary Keys

## Defining a Primary Key

Use the `@PrimaryKey()` annotation to mark a column as the primary key.

```dart
@PrimaryKey()
DataType id = DataType.INTEGER;
```

This is equivalent to creating a column with `primaryKey: true` in standard Sequelize.

## Auto-Generating Primary Keys

Often primary keys are also auto-incrementing integers or UUIDs.

### Auto-Increment Integer

```dart
@PrimaryKey()
@AutoIncrement()
DataType id = DataType.INTEGER;
```

### UUID

```dart
@PrimaryKey()
@Default.uniqid()
DataType id = DataType.UUID;
```

## Composite Primary Keys

Sequelize Dart supports composite primary keys. Simply add `@PrimaryKey()` to multiple fields.

```dart
class Enrollment {
  @PrimaryKey()
  DataType studentId = DataType.INTEGER;

  @PrimaryKey()
  DataType courseId = DataType.INTEGER;
}
```

## No Primary Key

If you want a table without a primary key (and want to prevent Sequelize from adding a default `id` column), set `noPrimaryKey: true` in the `@Table` annotation.

```dart
@Table(noPrimaryKey: true)
class Log {
  // ...
}
```
