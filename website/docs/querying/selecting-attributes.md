---
sidebar_position: 8
---

# Selecting Specific Attributes

Select only the columns you need:

```dart
final users = await Users.instance.findAll(
  attributes: QueryAttributes(
    include: [
      Users.instance.id,
      Users.instance.email,
      Users.instance.firstName,
    ],
  ),
);
```

Exclude specific columns:

```dart
final users = await Users.instance.findAll(
  attributes: QueryAttributes(
    exclude: [
      Users.instance.password,
      Users.instance.secretKey,
    ],
  ),
);
```
