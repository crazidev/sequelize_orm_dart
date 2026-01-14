---
sidebar_position: 5
---

# Query Conditions

Sequelize Dart provides a type-safe query builder using column extensions.

## Comparison Operators

```dart
// Equals
Users.instance.email.equals('user@example.com')

// Not equals
Users.instance.email.notEquals('user@example.com')

// Greater than
Users.instance.age.gt(18)

// Greater than or equal
Users.instance.age.gte(18)

// Less than
Users.instance.age.lt(65)

// Less than or equal
Users.instance.age.lte(65)
```

## Null Checks

```dart
// Is null
Users.instance.email.isNull()

// Is not null
Users.instance.email.isNotNull()
```

## String Operators

```dart
// Like (pattern matching)
Users.instance.email.like('%@example.com')

// Not like
Users.instance.email.notLike('%@example.com')

// Case-insensitive like (PostgreSQL)
Users.instance.email.iLike('%@example.com')
```

## List Operators

```dart
// In array
Users.instance.id.in_([1, 2, 3, 4, 5])

// Not in array
Users.instance.id.notIn([1, 2, 3])

// Between
Users.instance.age.between(18, 65)
```

## Logical Operators

Combine conditions with `and` and `or`:

```dart
// AND
Users.instance.email.isNotNull().and(
  Users.instance.age.gte(18),
)

// OR
Users.instance.email.equals('user1@example.com').or(
  Users.instance.email.equals('user2@example.com'),
)
```

## Complex Queries

```dart
final users = await Users.instance.findAll(
  where: Users.instance.email.isNotNull()
    .and(Users.instance.age.gte(18))
    .or(Users.instance.isActive.equals(true)),
);
```
