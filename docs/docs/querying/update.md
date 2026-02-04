---
sidebar_position: 3
---

# Update (Modifying Data)

You can update records in bulk using the static `update` method, or update a specific instance you have already retrieved.

## Bulk Update (Static Method)

Updates multiple records in the database that match the `where` condition.

```dart
// Update 'status' to 'active' for all users who have verified their email
final affectedRows = await Users.model.update(
  status: 'active',
  where: (user) => user.emailVerified.equals(true),
);

// Update specific fields for a specific user ID
await Users.model.update(
  firstName: 'Jane',
  lastName: 'Doe',
  where: (user) => user.id.equals(123),
);
```

## Updating Instances

If you already have a model instance (e.g. from `findOne`), you can modify its properties and call `save()` to persist changes.

```dart
final user = await Users.model.findOne(where: (u) => u.id.equals(1));

if (user != null) {
  // Update fields locally
  user.firstName = 'Updated Name';
  user.email = 'updated@example.com';
  
  // Persist changes to the database
  await user.save();
}
```
