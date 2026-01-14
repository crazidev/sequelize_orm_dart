---
sidebar_position: 3
---

# Using Associations

## Finding Records with Associations

Use the `include` parameter to load associated records:

```dart
// Single association
final user = await Users.instance.findOne(
  where: Users.instance.id.equals(1),
  include: [Users.instance.post],
);

// Multiple associations
final user = await Users.instance.findOne(
  where: Users.instance.id.equals(1),
  include: [
    Users.instance.post,
    Users.instance.posts,
  ],
);
```

## Filtering by Associated Data

You can filter records based on associated data:

```dart
// Find users who have posts
final usersWithPosts = await Users.instance.findAll(
  include: [
    Users.instance.posts,
  ],
  where: Users.instance.posts.isNotEmpty(),
);
```

## Nested Associations

Load nested associations (associations of associations):

```dart
// User -> Posts -> Comments
final user = await Users.instance.findOne(
  where: Users.instance.id.equals(1),
  include: [
    Users.instance.posts.include([
      Post.instance.comments,
    ]),
  ],
);
```
