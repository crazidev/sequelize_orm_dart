---
sidebar_position: 2
---

# Creating Records

## create

Creates a new record in the database.

Inserts a new row with the provided data and returns the created model instance.

**Parameters:**

- `data`: A map or model instance containing the data to insert

**Returns:** A `Future` that completes with the created model instance.

**Example:**

```dart
// Create using a map
final newUser = await Users.instance.create({
  'email': 'user@example.com',
  'firstName': 'John',
  'lastName': 'Doe',
});

// Create using a Create class (if available)
final user = Create<Users>()
  ..email = 'user@example.com'
  ..firstName = 'John'
  ..lastName = 'Doe';
final created = await Users.instance.create(user);
```

## Bulk Create

Create multiple records at once:

```dart
final users = await Users.instance.bulkCreate([
  {
    'email': 'user1@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
  },
  {
    'email': 'user2@example.com',
    'firstName': 'Jane',
    'lastName': 'Smith',
  },
]);
```
