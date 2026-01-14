---
sidebar_position: 1
---

# Finding Records

## findAll

Finds all records matching the query conditions.

Returns a list of model instances that match the specified criteria.
If no records match, returns an empty list.

**Parameters:**

- `where`: Optional query conditions to filter records
- `include`: Optional associations to include (eager loading)
- `order`: Optional sorting order
- `group`: Optional grouping clause
- `limit`: Optional maximum number of records to return
- `offset`: Optional number of records to skip
- `attributes`: Optional list of attributes to select

**Returns:** A `Future` that completes with a list of model instances.

**Example:**

```dart
// Find all users
final users = await Users.instance.findAll();

// Find users with conditions
final activeUsers = await Users.instance.findAll(
  where: Users.instance.email.isNotNull(),
  limit: 10,
);

// Find with associations
final usersWithPosts = await Users.instance.findAll(
  include: [Users.instance.posts],
);
```

## findOne

Finds a single record matching the query conditions.

Returns the first record that matches the specified criteria.
If no record matches, returns `null`.

**Parameters:**

- `where`: Optional query conditions to filter records
- `include`: Optional associations to include (eager loading)
- `order`: Optional sorting order
- `group`: Optional grouping clause
- `attributes`: Optional list of attributes to select

**Returns:** A `Future` that completes with a model instance or `null`.

**Example:**

```dart
// Find a user by email
final user = await Users.instance.findOne(
  where: Users.instance.email.equals('user@example.com'),
);

// Find with associations
final userWithPost = await Users.instance.findOne(
  where: Users.instance.id.equals(1),
  include: [Users.instance.post],
);
```
