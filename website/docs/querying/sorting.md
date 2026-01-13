---
sidebar_position: 6
---

# Sorting

Use the `order` parameter to sort results:

```dart
// Ascending order
final users = await Users.instance.findAll(
  order: Users.instance.id.asc(),
);

// Descending order
final users = await Users.instance.findAll(
  order: Users.instance.id.desc(),
);

// Multiple columns
final users = await Users.instance.findAll(
  order: [
    Users.instance.lastName.asc(),
    Users.instance.firstName.asc(),
  ],
);
```
