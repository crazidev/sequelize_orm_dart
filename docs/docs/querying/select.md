---
sidebar_position: 1
---

# Select (Reading Data)

Reading data is done primarily through `findAll` and `findOne`. You can fetch simple records or eagerly load associated data.

## Basic Selection

Retrieve all records or a single record matching specific criteria.

```dart
// Find all users
final users = await Users.model.findAll();

// Find a single user by email
final user = await Users.model.findOne(
  where: (user) => user.email.equals('user@example.com'),
);
```

## Selecting Attributes

Control exactly which columns are returned from the database.

```dart
// Only fetch id and email
Users.model.findAll(
  attributes: QueryAttributes.include(['id', 'email']),
);

// Fetch everything except password
Users.model.findAll(
  attributes: QueryAttributes.exclude(['password']),
);
```

## Querying with Associations (Eager Loading)

You can retrieve exact relations in a single query using the `include` option. This is often called "eager loading".

```dart
// Fetch users and include their posts
final usersWithPosts = await Users.model.findAll(
  include: (include) => [
    include.posts(), // Include the 'posts' association
  ],
);

// Fetch a user with a specific post
final userWithSpecificPost = await Users.model.findOne(
  where: (user) => user.id.equals(1),
  include: (include) => [
    include.post(),
  ],
);
```

For more complex relation filtering, you can nest `where` clauses inside includes if supported, or filter at the top level using `$` syntax.

```dart
// Find users and include only their "published" posts
// (Note: This depends on how your association filtering is set up)
final userAndPosts = await Users.model.findAll(
  include: (include) => [
    include.posts(),
  ],
  where: (user) => const Column('$posts.is_published$').equals(true),
);
```
