---
sidebar_position: 9
---

# Complete Query Examples

## Example 1: Complex Search

```dart
final activeUsers = await Users.instance.findAll(
  where: Users.instance.email.isNotNull()
    .and(Users.instance.age.between(18, 65))
    .and(Users.instance.isActive.equals(true)),
  order: [
    Users.instance.lastName.asc(),
    Users.instance.firstName.asc(),
  ],
  limit: 50,
  include: [Users.instance.posts],
);
```

## Example 2: Pagination with Search

```dart
Future<Map<String, dynamic>> searchUsers({
  String? email,
  int? minAge,
  int page = 1,
  int pageSize = 20,
}) async {
  var where = Users.instance.email.isNotNull();

  if (email != null) {
    where = where.and(Users.instance.email.like('%$email%'));
  }

  if (minAge != null) {
    where = where.and(Users.instance.age.gte(minAge));
  }

  final users = await Users.instance.findAll(
    where: where,
    order: Users.instance.id.desc(),
    limit: pageSize,
    offset: (page - 1) * pageSize,
  );

  final total = await Users.instance.count(where: where);

  return {
    'users': users,
    'total': total,
    'page': page,
    'pageSize': pageSize,
    'totalPages': (total / pageSize).ceil(),
  };
}
```

## Example 3: Aggregations

```dart
// Count
final userCount = await Users.instance.count();

// Max
final maxAge = await Users.instance.max(Users.instance.age);

// Min
final minAge = await Users.instance.min(Users.instance.age);

// Sum
final totalPosts = Post.instance.sum(Post.instance.likes);
```

## Best Practices

1. **Use type-safe queries**: Always use the column extensions (e.g., `Users.instance.email.equals()`) instead of raw strings.

2. **Eager load associations**: Include associations when you know you'll need them to avoid N+1 queries.

3. **Limit results**: Always use `limit` when fetching large datasets to avoid memory issues.

4. **Index frequently queried columns**: Add database indexes on columns used in `where` clauses for better performance.

5. **Use transactions for multiple operations**: When performing multiple related operations, use transactions to ensure data consistency.
