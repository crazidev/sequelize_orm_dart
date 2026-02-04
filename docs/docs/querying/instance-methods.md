---
sidebar_position: 4
---

# Instance Methods

Instances in Sequelize Dart come with several helpful methods to manage their state.

## save()

Persists the current state of the instance to the database. If the instance was retrieved from the database, it performs an `UPDATE`. If it's a new instance (not yet created), it performs an `INSERT`.

```dart
user.firstName = 'New Name';
await user.save();
```

## reload()

Refreshes the instance with the latest data from the database. This is useful if you suspect the data might have changed elsewhere or if you want to reset local changes.

```dart
final user = await Users.model.findOne(where: (u) => u.id.equals(1));

// ... some operations ...

// Re-fetch data from DB
await user.reload();
```
