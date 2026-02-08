---
sidebar_position: 8
---

# Nullability

By default, columns in Sequelize allow `NULL` values (unless they are primary keys).

## Disallowing Null Values

To enforce that a column cannot be null, use the `@NotNull()` annotation. This adds a `NOT NULL` constraint to the database column and performs a validation check.

```dart
@NotNull()
DataType username = DataType.STRING;
```

## Explicitly Allowing Null

You can use `@AllowNull()` to explicitly state that a column can be null. This is the default behavior but can be useful for clarity.

```dart
@AllowNull()
DataType bio = DataType.TEXT;
```

## Omit Null

To prevent `null` values from being inserted into the database (using the default value instead), you can use the `omitNull` option in the `@Table` annotation.

```dart
@Table(omitNull: true)
class User {
  // ...
}
```
