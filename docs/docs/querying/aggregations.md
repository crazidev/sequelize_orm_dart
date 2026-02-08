---
sidebar_position: 7
---

# Aggregations & Utilities

Perform calculations directly on the database.

## Count, Sum, Max, Min

```dart
// Count
final count = await Users.model.count(where: (u) => u.isActive.eq(true));

// Sum
final totalViews = await Post.model.sum((p) => p.views);

// Sum - with where clause
final userViews = await Post.model.sum(
  (p) => p.views,
  where: (p) => p.userId.eq(1),
);

// Max/Min
final maxScore = await Users.model.max((u) => u.score);
final minAge = await Users.model.min((u) => u.age);
```

## Increment & Decrement

Atomically update numeric fields.

```dart
// Increment views by 1
await Post.model.increment(
  views: 1,
  where: (p) => p.id.eq(post.id),
);

// Increment multiple fields
await Post.model.increment(
  views: 10,
  likes: 2,
  where: (p) => p.userId.eq(1),
);

// Decrement
await Post.model.decrement(
  views: 1,
  where: (p) => p.id.eq(2),
);
```
