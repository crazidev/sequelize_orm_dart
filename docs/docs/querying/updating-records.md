---
sidebar_position: 3
---

# Updating Records

## update

Updates records matching the query conditions.

Modifies existing records that match the specified criteria.

**Parameters:**

- `data`: A map containing the fields to update
- `where`: Optional query conditions to filter which records to update

**Returns:** A `Future` that completes with the number of affected rows.

**Example:**

```dart
// Update all matching records
final affected = await Users.instance.update(
  data: {'firstName': 'Jane'},
  where: Users.instance.email.equals('user@example.com'),
);

// Update a single record by ID
await Users.instance.update(
  data: {'lastName': 'Smith'},
  where: Users.instance.id.equals(1),
);
```

## Updating Individual Instances

You can also update a model instance directly:

```dart
final user = await Users.instance.findOne(
  where: Users.instance.id.equals(1),
);

if (user != null) {
  user.firstName = 'Updated Name';
  await user.save();
}
```
