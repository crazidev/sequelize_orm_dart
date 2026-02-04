---
sidebar_position: 5
---

# Query Conditions (Where)

Use the `where` callback to build type-safe conditions.

## Comparison Operators

```dart
// Equals
(user) => user.email.equals('user@example.com')

// Not equals
(user) => user.email.notEquals('user@example.com')

// Greater than / Less than
(user) => user.age.gt(18)         // Greater than
(user) => user.age.lte(65)        // Less than or equal

// Between
(user) => user.age.between(18, 65)

// In / Not In
(user) => user.status.in_(['active', 'pending'])
(user) => user.status.notIn(['banned'])
```

## Null Checks

```dart
(user) => user.deletedAt.isNull()
(user) => user.email.isNotNull()
```

## String Operators

```dart
// Like (Case-sensitive)
(user) => user.username.like('admin%')

// iLike (Case-insensitive - Postgres only)
(user) => user.username.iLike('admin%')

// Not Like
(user) => user.username.notLike('%test%')
```

## Logical Combinations

You can combine multiple conditions using `and`, `or`, and `not`.

```dart
// AND (Implicit or explicit)
Users.model.findAll(
  where: (user) => and([
    user.age.gte(18),
    user.isActive.equals(true),
  ]),
);

// OR
Users.model.findAll(
  where: (user) => or([
    user.role.equals('admin'),
    user.role.equals('moderator'),
  ]),
);

// NOT
Users.model.findAll(
  where: (user) => not([
    user.status.equals('banned'),
  ]),
);

// Nested Combinations
Users.model.findAll(
  where: (user) => and([
    user.email.isNotNull(),
    or([
      user.role.equals('admin'),
      user.permissions.contains('superuser'),
    ]),
  ]),
);
```

## Advanced Filtering

### Casting

Cast columns using the `::` syntax within a `Column` definition.

```dart
Users.model.findOne(
  where: (user) => and([
    const Column('id::text').eq('1'),
  ]),
);
```

### Referencing Associated Models

Filter using columns from associated models in the top-level `where` clause using the `$` syntax.

```dart
Users.model.findOne(
  include: (include) => [include.post()],
  where: (user) => and([
    const Column('$post.views$').gt(100),
  ]),
);
```
