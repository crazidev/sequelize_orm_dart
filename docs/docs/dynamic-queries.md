# Dynamic Queries

Dynamic queries use string-based column names, making them useful for building queries programmatically or when column names are determined at runtime.

## Introduction

Dynamic queries use the `Query` class directly with string column names and operator functions. This approach is useful when:

- Column names are dynamic or determined at runtime
- Migrating from legacy code
- Building queries programmatically
- Column names come from user input (with proper sanitization)

## Basic Syntax

Dynamic queries use operator functions with string column names:

```dart
var users = await Users.instance.findAll(
  Query(
    where: equal('email', 'user@example.com'),
    order: [['id', 'DESC']],
  ),
);
```

## Operators

### Comparison Operators

```dart
// Equal
where: equal('id', 1)

// Not equal
where: notEqual('id', 1)

// Using ComparisonOperator for advanced operators
where: ComparisonOperator(
  column: 'age',
  value: {'$gt': 18},
)
```

### Logical Operators

```dart
// AND
where: and([
  equal('email', 'user@example.com'),
  equal('firstName', 'John'),
])

// OR
where: or([
  equal('id', 1),
  equal('id', 2),
])

// NOT
where: not([
  equal('email', 'admin@example.com'),
])
```

## Complete Examples

### Simple Filter

```dart
var user = await Users.instance.findOne(
  Query(
    where: equal('email', 'user@example.com'),
  ),
);
```

### Multiple Conditions

```dart
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

### Using ComparisonOperator

For operators not available as direct functions, use `ComparisonOperator`:

```dart
var users = await Users.instance.findAll(
  Query(
    where: ComparisonOperator(
      column: 'age',
      value: {
        '$gt': 18,
        '$lt': 65,
      },
    ),
  ),
);
```

Supported comparison operators in `ComparisonOperator`:
- `$gt` - Greater than
- `$gte` - Greater than or equal
- `$lt` - Less than
- `$lte` - Less than or equal
- `$like` - LIKE pattern
- `$ilike` - Case-insensitive LIKE (PostgreSQL)
- `$in` - IN list
- `$notIn` - NOT IN list

## Ordering

Use string column names in order clauses:

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

## Dynamic Column Names

Dynamic queries are useful when column names are determined at runtime:

```dart
String sortColumn = getUserPreference(); // e.g., 'lastName' or 'firstName'

var users = await Users.instance.findAll(
  Query(
    order: [[sortColumn, 'ASC']],
  ),
);
```

## When to Use Dynamic Queries

Use dynamic queries when:

1. **Column names are dynamic** - Determined at runtime
2. **Building queries programmatically** - Based on user input or configuration
3. **Migrating legacy code** - Existing code uses string-based queries
4. **Flexibility needed** - Column names come from external sources

## Security Considerations

⚠️ **Important**: When using dynamic queries with user input, always validate and sanitize column names to prevent SQL injection.

```dart
// ❌ BAD - Direct user input
String userColumn = request.queryParams['sort'];
var users = await Users.instance.findAll(
  Query(order: [[userColumn, 'ASC']]), // Dangerous!
);

// ✅ GOOD - Validate against allowed columns
List<String> allowedColumns = ['id', 'email', 'firstName', 'lastName'];
String userColumn = request.queryParams['sort'];
if (!allowedColumns.contains(userColumn)) {
  userColumn = 'id'; // Default to safe column
}
var users = await Users.instance.findAll(
  Query(order: [[userColumn, 'ASC']]),
);
```

## Comparison with Typed Queries

| Feature | Dynamic Queries | Typed Queries |
|---------|----------------|---------------|
| **Column Names** | Strings | Typed with autocomplete |
| **Type Safety** | Runtime | Compile-time |
| **Autocomplete** | No | Yes |
| **Refactoring** | Manual | Automatic |
| **Dynamic Columns** | Yes | No |
| **Recommended** | For dynamic cases | For static queries |

## Migration to Typed Queries

If your column names are static, consider migrating to typed queries:

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

## Next Steps

- Learn about [Typed Queries](./typed-queries.md) for type-safe querying
- See [Operators](./operators.md) for all available operators
- Check out [Examples](./examples.md) for common patterns
