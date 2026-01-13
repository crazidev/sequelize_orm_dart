---
sidebar_position: 6
---

# Primary Keys

Define primary keys using the `primaryKey` option:

```dart
@ModelAttributes(
  name: 'id',
  type: DataType.INTEGER,
  primaryKey: true,
)
dynamic id;
```

## Composite Primary Keys

For composite primary keys, mark multiple fields:

```dart
@ModelAttributes(
  name: 'user_id',
  type: DataType.INTEGER,
  primaryKey: true,
)
dynamic userId;

@ModelAttributes(
  name: 'role_id',
  type: DataType.INTEGER,
  primaryKey: true,
)
dynamic roleId;
```
