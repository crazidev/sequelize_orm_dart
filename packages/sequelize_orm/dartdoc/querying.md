Sequelize Dart provides a comprehensive, type-safe API for reading, creating,
updating, and deleting data.

## Select (Reading Data)

```dart
// Find all users
final users = await Users.model.findAll();

// Find one user by email
final user = await Users.model.findOne(
  where: (u) => u.email.eq('user@example.com'),
);

// Select specific attributes
final names = await Users.model.findAll(
  attributes: QueryAttributes.include(['id', 'email']),
);
```

## Operators

Type-safe comparison, string, and logical operators are available on every
column reference.

```dart
// Comparison
(u) => u.age.gt(18)
(u) => u.age.between(18, 65)
(u) => u.status.in_(['active', 'pending'])

// String
(u) => u.username.like('admin%')
(u) => u.username.iLike('admin%')   // PostgreSQL

// Null checks
(u) => u.deletedAt.isNull()

// Logical combinations
(u) => and([u.age.gte(18), u.isActive.eq(true)])
(u) => or([u.role.eq('admin'), u.role.eq('moderator')])
```

## Insert

```dart
final user = await Users.model.create(
  CreateUsers(email: 'bob@example.com', firstName: 'Bob', lastName: 'Jones'),
);
```

## Update

```dart
// Bulk update
await Users.model.update(
  lastName: 'Johnson',
  where: (u) => u.id.eq(1),
);

// Instance update
await user.update({'lastName': 'Johnson'});
```

## Delete

```dart
// Soft delete (paranoid model)
await Users.model.destroy(where: (u) => u.id.eq(1));

// Hard delete
await Users.model.destroy(where: (u) => u.id.eq(1), force: true);

// Restore soft-deleted record
await Users.model.restore(where: (u) => u.id.eq(1));
```

## Sorting & Pagination

```dart
final page = await Users.model.findAll(
  order: [OrderItem(column: 'created_at', direction: OrderDirection.DESC)],
  limit: 10,
  offset: 20,
);
```

## Aggregations

```dart
final count = await Users.model.count();
final maxAge = await Users.model.max((u) => u.age);
final total = await Users.model.sum((u) => u.balance);
```
