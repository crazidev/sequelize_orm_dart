---
sidebar_position: 4
---

# Eager Loading

Eager loading fetches associated data in a single query, improving performance:

```dart
// Without eager loading (N+1 queries)
final users = await Users.instance.findAll();
for (final user in users) {
  // This would trigger a separate query for each user
  final posts = await Post.instance.findAll(
    where: Post.instance.userId.equals(user.id),
  );
}

// With eager loading (1 query with JOIN)
final users = await Users.instance.findAll(
  include: [Users.instance.posts],
);
// All posts are loaded in a single query
```
