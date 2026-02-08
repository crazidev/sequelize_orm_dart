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

### JSON Querying

Columns defined with `DataType.JSON` or `DataType.JSONB` are generated as `JsonColumn`, which provides a fluent API for building JSON path queries.

#### Navigating JSON keys

Use `.key()` to access a key in the JSON object:

```dart
// SQL: "metadata"->'source'
PostDetails.model.findAll(
  where: (p) => p.metadata.key('source').eq('"seeder"'),
);
```

> **Note:** Without `.unquote()`, the `->` operator returns a JSON value. String comparisons must include the JSON quotes (e.g. `'"seeder"'`).

#### Navigating array indices

Use `.at()` to access an element by index:

```dart
// SQL: "metadata"->'tags'->0
PostDetails.model.findOne(
  where: (p) => p.metadata.key('tags').at(0).eq('"dart"'),
);
```

#### Unquoting (text extraction)

Use `.unquote()` to switch from `->` (JSON) to `->>` (text). This returns a `Column<String>`, so all string operators (`.like()`, `.startsWith()`, `.iLike()`, etc.) are type-safe:

```dart
// SQL: "metadata"->'tags'->>0 = 'dart'
PostDetails.model.findOne(
  where: (p) => p.metadata.key('tags').at(0).unquote().eq('dart'),
);

// SQL: "metadata"->>'source' LIKE '%seed%'
PostDetails.model.findAll(
  where: (p) => p.metadata.key('source').unquote().like('%seed%'),
);
```

#### Nested paths

Chain `.key()` and `.at()` to traverse deeply nested structures:

```dart
// SQL: "metadata"->'author'->'address'->>'city' = 'London'
PostDetails.model.findOne(
  where: (p) => p.metadata
      .key('author')
      .key('address')
      .key('city')
      .unquote()
      .eq('London'),
);
```

#### Combining with other conditions

JSON conditions compose with `and()`, `or()`, and `not()` like any other condition:

```dart
PostDetails.model.findAll(
  where: (p) => and([
    p.id.eq(1),
    p.metadata.key('tags').at(0).unquote().eq('dart'),
    or([
      p.metadata.key('source').unquote().eq('seeder'),
      p.metadata.key('source').unquote().eq('api'),
    ]),
  ]),
);
```

#### Raw string fallback

You can still use `Column` with a raw string path if you prefer:

```dart
const Column('metadata.tags[0]:unquote').eq('dart')
```

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
