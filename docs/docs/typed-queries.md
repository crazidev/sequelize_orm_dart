# Typed Queries

Typed queries provide type-safe query building with autocomplete support. This is the recommended approach for building queries in Sequelize Dart.

## Introduction

Typed queries use a callback function that provides a typed query builder (`q`) with autocomplete for all model columns. This ensures type safety and makes refactoring easier.

## Basic Syntax

The typed query syntax uses a callback function:

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.gt(1),
    order: [[q.id, 'DESC']],
  ),
);
```

The `q` parameter provides typed access to all model columns with autocomplete.

## Column Access

Access columns through the typed query builder:

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.email.eq('user@example.com'),
  ),
);
```

All columns from your model are available with autocomplete:
- `q.id`
- `q.email`
- `q.firstName`
- `q.lastName`
- etc.

## Operators

### Comparison Operators

```dart
// Equal
where: q.id.eq(1)

// Not equal
where: q.id.ne(1)

// Greater than
where: q.id.gt(1)

// Greater than or equal
where: q.id.gte(1)

// Less than
where: q.id.lt(10)

// Less than or equal
where: q.id.lte(10)
```

### Null Checks

```dart
// IS NULL
where: q.email.isNull()

// IS NOT NULL
where: q.email.isNotNull()
```

### String Operators

```dart
// LIKE
where: q.email.like('%@example.com')

// NOT LIKE
where: q.email.notLike('%@test.com')

// Starts with
where: q.email.startsWith('user')

// Ends with
where: q.email.endsWith('@example.com')

// Contains (substring)
where: q.email.substring('test')

// Case-insensitive LIKE (PostgreSQL)
where: q.email.iLike('%@EXAMPLE.COM')

// Case-insensitive NOT LIKE (PostgreSQL)
where: q.email.notILike('%@TEST.COM')
```

### List Operators

```dart
// IN
where: q.id.in_([1, 2, 3])

// NOT IN
where: q.id.notIn([4, 5, 6])
```

### Range Operators

```dart
// BETWEEN
where: q.id.between(1, 10)

// NOT BETWEEN
where: q.id.notBetween(11, 20)
```

## Logical Operators

Combine conditions using logical operators:

### AND

```dart
where: q.id.gt(1).and(q.email.like('%@example.com'))
```

### OR

```dart
where: q.id.eq(1).or(q.id.eq(2))
```

### NOT

```dart
where: q.email.notLike('%@test.com')
```

### Complex Combinations

```dart
where: q.id.gt(1)
  .and(q.email.like('%@example.com'))
  .or(q.firstName.eq('John'))
```

## Ordering

Use typed columns in order clauses:

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    order: [
      [q.lastName, 'ASC'],
      [q.firstName, 'ASC'],
    ],
  ),
);
```

## Complete Examples

### Simple Filter

```dart
var user = await Users.instance.findOne(
  (q) => Query(
    where: q.email.eq('user@example.com'),
  ),
);
```

### Multiple Conditions

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.gt(1).and(q.email.like('%@example.com')),
    order: [[q.id, 'DESC']],
    limit: 10,
  ),
);
```

### Complex Query

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.gt(1)
      .or(q.email.like('crazidev%'))
      .and(q.firstName.isNotNull()),
    order: [
      [q.lastName, 'ASC'],
      [q.firstName, 'ASC'],
    ],
    limit: 20,
    offset: 0,
  ),
);
```

### List Operations

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.in_([1, 2, 3, 4, 5]),
    order: [[q.id, 'DESC']],
  ),
);
```

### Range Queries

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.between(10, 100),
    order: [[q.id, 'ASC']],
  ),
);
```

## Benefits of Typed Queries

1. **Autocomplete** - IDE provides autocomplete for all column names
2. **Type Safety** - Compile-time checking prevents typos
3. **Refactoring** - Renaming columns updates queries automatically
4. **Documentation** - Column names are self-documenting
5. **Error Prevention** - Invalid column names caught at compile time

## Migration from Dynamic Queries

To migrate from dynamic queries:

**Before (Dynamic):**
```dart
var users = await Users.instance.findAll(
  Query(
    where: equal('email', 'user@example.com'),
  ),
);
```

**After (Typed):**
```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.email.eq('user@example.com'),
  ),
);
```

## Limitations

- Column names must be known at compile time
- Cannot use dynamic column names (use [Dynamic Queries](./dynamic-queries.md) instead)

## Next Steps

- See [Operators](./operators.md) for all available operators
- Learn about [Dynamic Queries](./dynamic-queries.md) for string-based queries
- Check out [Examples](./examples.md) for more patterns
