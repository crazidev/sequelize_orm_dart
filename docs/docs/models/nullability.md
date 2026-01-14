---
sidebar_position: 8
---

# Nullability

Control whether columns can be null:

```dart
// Nullable column (default)
@ModelAttributes(
  name: 'middle_name',
  type: DataType.STRING,
  allowNull: true,
)
dynamic middleName;

// Non-nullable column
@ModelAttributes(
  name: 'email',
  type: DataType.STRING,
  allowNull: false,
)
dynamic email;
```
