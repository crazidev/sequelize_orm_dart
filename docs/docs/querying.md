# Querying

Sequelize Dart provides powerful querying capabilities through the `findAll()` and `findOne()` methods. This guide covers the basics of querying your models.

## Overview

There are two approaches to building queries:

1. **Typed Queries** - Type-safe queries with autocomplete (recommended)
2. **Dynamic Queries** - String-based column names (legacy, still supported)

This page covers the general querying concepts. See [Typed Queries](./typed-queries.md) and [Dynamic Queries](./dynamic-queries.md) for detailed information about each approach.

## Basic Queries

### Find All Records

Get all records from a table:

```dart
var allUsers = await Users.instance.findAll();
```

Returns: `List<$UsersValues>`

### Find One Record

Get a single record:

```dart
var user = await Users.instance.findOne();
```

Returns: `$UsersValues?` (null if not found)

## Query Options

The `Query` class provides several options for filtering, sorting, and pagination:

```dart
Query({
  where: QueryOperator?,      // Where conditions
  order: List<List<String>>?, // Order by clauses
  limit: int?,                // Maximum records
  offset: int?,               // Skip records
  include: List<dynamic>?,     // Associations (future)
})
```

### Where Conditions

Filter records using `where`:

```dart
// Using typed queries (recommended)
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.gt(1),
  ),
);

// Using dynamic queries
var users = await Users.instance.findAll(
  Query(
    where: equal('id', 1),
  ),
);
```

See [Operators](./operators.md) for all available operators.

### Ordering

Sort results using `order`:

```dart
var users = await Users.instance.findAll(
  Query(
    order: [
      ['lastName', 'ASC'],
      ['firstName', 'ASC'],
    ],
  ),
);
```

Order direction: `'ASC'` or `'DESC'`

### Limiting Results

Limit the number of results:

```dart
var users = await Users.instance.findAll(
  Query(
    limit: 10,
  ),
);
```

### Pagination

Use `limit` and `offset` for pagination:

```dart
var page = 1;
var pageSize = 10;

var users = await Users.instance.findAll(
  Query(
    limit: pageSize,
    offset: (page - 1) * pageSize,
  ),
);
```

## Complete Query Examples

### Simple Filter

```dart
// Find users with specific email
var user = await Users.instance.findOne(
  Query(
    where: equal('email', 'user@example.com'),
  ),
);
```

### Multiple Conditions

```dart
// Find users with AND conditions
var users = await Users.instance.findAll(
  Query(
    where: and([
      equal('email', 'user@example.com'),
      equal('firstName', 'John'),
    ]),
  ),
);
```

### Complex Query

```dart
// Find users with complex conditions, ordering, and pagination
var users = await Users.instance.findAll(
  Query(
    where: and([
      or([
        equal('email', 'user1@example.com'),
        equal('email', 'user2@example.com'),
      ]),
      notEqual('id', 0),
    ]),
    order: [
      ['lastName', 'ASC'],
      ['firstName', 'ASC'],
    ],
    limit: 20,
    offset: 0,
  ),
);
```

## Typed vs Dynamic Queries

### Typed Queries (Recommended)

Type-safe queries with autocomplete:

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.gt(1).and(q.email.like('%@example.com')),
    order: [[q.id, 'DESC']],
  ),
);
```

**Benefits:**
- Autocomplete for column names
- Type safety
- Refactoring support
- Compile-time error checking

See [Typed Queries](./typed-queries.md) for details.

### Dynamic Queries

String-based column names:

```dart
var users = await Users.instance.findAll(
  Query(
    where: equal('id', 1),
    order: [['id', 'DESC']],
  ),
);
```

**Use when:**
- Column names are dynamic
- Migrating from legacy code
- Building queries programmatically

See [Dynamic Queries](./dynamic-queries.md) for details.

## Creating Records

Create new records:

```dart
var newUser = await Users.instance.create({
  'email': 'newuser@example.com',
  'firstName': 'John',
  'lastName': 'Doe',
});
```

Returns: `$UsersValues` with the created record (including generated ID).

## Error Handling

Handle query errors:

```dart
try {
  var user = await Users.instance.findOne(
    Query(where: equal('id', 999)),
  );

  if (user == null) {
    print('User not found');
  }
} on BridgeException catch (e) {
  // Bridge-specific errors (Dart server only)
  print('Bridge error: ${e.message}');
  print('Original error: ${e.originalError}');
  if (e.sql != null) {
    print('SQL: ${e.sql}');
  }
} catch (e) {
  print('Error: $e');
}
```

## Performance Tips

1. **Use indexes** - Ensure database columns used in `where` clauses are indexed
2. **Limit results** - Always use `limit` when fetching large datasets
3. **Use pagination** - For large result sets, implement pagination
4. **Connection pooling** - Configure appropriate pool sizes (see [Connections](./connections.md))

## Next Steps

- Learn about [Typed Queries](./typed-queries.md) for type-safe querying
- Explore [Dynamic Queries](./dynamic-queries.md) for string-based queries
- Check out [Operators](./operators.md) for all available operators
- See [Examples](./examples.md) for common use cases
