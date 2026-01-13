---
sidebar_position: 7
---

# Auto Increment

Enable auto-increment for integer primary keys:

```dart
@ModelAttributes(
  name: 'id',
  type: DataType.INTEGER,
  primaryKey: true,
  autoIncrement: true,
)
dynamic id;
```
