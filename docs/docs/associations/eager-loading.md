---
sidebar_position: 4
---

# Eager Loading

Eager loading fetches associated data in a single query (using `JOIN`s) or separate queries, improving performance by avoiding the N+1 problem.

## Basic Eager Loading

To eager load associations, use the `include` option.

```dart
// Fetch users and their posts in a single query
final users = await User.instance.findAll(
  include: (u) => [
    u.posts(),
  ],
);
```

## Required Eager Loading (Inner Join)

By default, Sequelize uses a `LEFT OUTER JOIN`, returning the main model records even if they have no associated records. To force an `INNER JOIN` (only return records that _have_ the association), set `required: true`.

```dart
final usersWithPosts = await User.instance.findAll(
  include: (u) => [
    u.posts(
      required: true, // Only return users who have posts
    ),
  ],
);
```

## Filtered Eager Loading

You can filter the associated records using the `where` option within the include.

```dart
final users = await User.instance.findAll(
  include: (u) => [
    u.posts(
      where: (p) => p.title.like('%Sequelize%'),
    ),
  ],
);
```

If you combine `where` with `required: false` (default), it acts like a `LEFT JOIN` where the `ON` condition includes your filter. If you use `required: true`, it behaves like a standard `INNER JOIN` with filtering.

## Right Join

You can perform a `RIGHT JOIN` by setting `right: true`. This will return all associated records (posts), and the main records (users) only if they match.

```dart
final users = await User.instance.findAll(
  include: (u) => [
    u.posts(
      right: true, // RIGHT OUTER JOIN
    ),
  ],
);
```

## Nested Eager Loading

To load associations of associations (e.g., User -> Posts -> Comments), nest the `include`.

```dart
final users = await User.instance.findAll(
  include: (u) => [
    u.posts(
      include: (p) => [
        p.comments(), // Load comments for each post
      ],
    ),
  ],
);
```

## Including All Associations

To include all associations of a model, you can use the `all: true` option with a manual `IncludeBuilder`.

```dart
final users = await User.instance.findAll(
  include: (u) => [
    IncludeBuilder(all: true),
  ],
);
```

To recursively include _everything_ (not recommended for large schemas):

```dart
final users = await User.instance.findAll(
  include: (u) => [
    IncludeBuilder(all: true, nested: true),
  ],
);
```

## Separate Queries

For one-to-many or many-to-many relationships, `JOIN`s can sometimes result in duplicated data or performance issues with limits. You can use `separate: true` to run the association query separately.

```dart
final users = await User.instance.findAll(
  include: (u) => [
    u.posts(
      separate: true, // Runs a separate query for posts
      limit: 10,      // Limit posts per user (only works with separate: true)
    ),
  ],
);
```
