# Operators

Sequelize Dart provides a comprehensive set of operators for building query conditions. Operators can be used in both typed and dynamic queries.

## Logical Operators

Logical operators combine multiple conditions.

### AND

Combine conditions with AND logic:

```dart
// Typed
where: q.id.gt(1).and(q.email.like('%@example.com'))

// Dynamic
where: and([
  equal('id', 1),
  equal('email', 'user@example.com'),
])
```

### OR

Combine conditions with OR logic:

```dart
// Typed
where: q.id.eq(1).or(q.id.eq(2))

// Dynamic
where: or([
  equal('id', 1),
  equal('id', 2),
])
```

### NOT

Negate a condition:

```dart
// Typed
where: q.email.notLike('%@test.com')

// Dynamic
where: not([
  equal('email', 'admin@example.com'),
])
```

### Complex Combinations

Combine multiple logical operators:

```dart
// Typed
where: q.id.gt(1)
  .and(q.email.like('%@example.com'))
  .or(q.firstName.eq('John'))

// Dynamic
where: and([
  or([
    equal('email', 'user1@example.com'),
    equal('email', 'user2@example.com'),
  ]),
  notEqual('id', 0),
])
```

## Basic Comparison Operators

### Equal

```dart
// Typed
where: q.id.eq(1)

// Dynamic
where: equal('id', 1)
```

### Not Equal

```dart
// Typed
where: q.id.ne(1)

// Dynamic
where: notEqual('id', 1)
```

### IS NULL / IS NOT NULL

```dart
// Typed
where: q.email.isNull()
where: q.email.isNotNull()

// Dynamic (using ComparisonOperator)
where: ComparisonOperator(
  column: 'email',
  value: {'$is': null},
)
where: ComparisonOperator(
  column: 'email',
  value: {'$not': null},
)
```

## Number Comparison Operators

### Greater Than

```dart
// Typed
where: q.id.gt(1)

// Dynamic
where: ComparisonOperator(
  column: 'id',
  value: {'$gt': 1},
)
```

### Greater Than or Equal

```dart
// Typed
where: q.id.gte(1)

// Dynamic
where: ComparisonOperator(
  column: 'id',
  value: {'$gte': 1},
)
```

### Less Than

```dart
// Typed
where: q.id.lt(10)

// Dynamic
where: ComparisonOperator(
  column: 'id',
  value: {'$lt': 10},
)
```

### Less Than or Equal

```dart
// Typed
where: q.id.lte(10)

// Dynamic
where: ComparisonOperator(
  column: 'id',
  value: {'$lte': 10},
)
```

### Between

```dart
// Typed
where: q.id.between(1, 10)

// Dynamic
where: ComparisonOperator(
  column: 'id',
  value: {'$between': [1, 10]},
)
```

### Not Between

```dart
// Typed
where: q.id.notBetween(11, 20)

// Dynamic
where: ComparisonOperator(
  column: 'id',
  value: {'$notBetween': [11, 20]},
)
```

## List Operators

### IN

Check if value is in a list:

```dart
// Typed
where: q.id.in_([1, 2, 3])

// Dynamic
where: ComparisonOperator(
  column: 'id',
  value: {'$in': [1, 2, 3]},
)
```

### NOT IN

Check if value is not in a list:

```dart
// Typed
where: q.id.notIn([4, 5, 6])

// Dynamic
where: ComparisonOperator(
  column: 'id',
  value: {'$notIn': [4, 5, 6]},
)
```

## String Operators

### LIKE

Pattern matching:

```dart
// Typed
where: q.email.like('%@example.com')

// Dynamic
where: ComparisonOperator(
  column: 'email',
  value: {'$like': '%@example.com'},
)
```

### NOT LIKE

```dart
// Typed
where: q.email.notLike('%@test.com')

// Dynamic
where: ComparisonOperator(
  column: 'email',
  value: {'$notLike': '%@test.com'},
)
```

### Starts With

```dart
// Typed
where: q.email.startsWith('user')

// Dynamic (using LIKE)
where: ComparisonOperator(
  column: 'email',
  value: {'$like': 'user%'},
)
```

### Ends With

```dart
// Typed
where: q.email.endsWith('@example.com')

// Dynamic (using LIKE)
where: ComparisonOperator(
  column: 'email',
  value: {'$like': '%@example.com'},
)
```

### Contains (Substring)

```dart
// Typed
where: q.email.substring('test')

// Dynamic (using LIKE)
where: ComparisonOperator(
  column: 'email',
  value: {'$like': '%test%'},
)
```

### Case-Insensitive LIKE (PostgreSQL)

```dart
// Typed
where: q.email.iLike('%@EXAMPLE.COM')

// Dynamic
where: ComparisonOperator(
  column: 'email',
  value: {'$iLike': '%@EXAMPLE.COM'},
)
```

### Case-Insensitive NOT LIKE (PostgreSQL)

```dart
// Typed
where: q.email.notILike('%@TEST.COM')

// Dynamic
where: ComparisonOperator(
  column: 'email',
  value: {'$notILike': '%@TEST.COM'},
)
```

## Regex Operators (PostgreSQL)

### REGEXP

```dart
// Dynamic only
where: ComparisonOperator(
  column: 'email',
  value: {'$regexp': '^[a-z]+@example\\.com$'},
)
```

### NOT REGEXP

```dart
// Dynamic only
where: ComparisonOperator(
  column: 'email',
  value: {'$notRegexp': '^test@'},
)
```

### Case-Insensitive REGEXP (PostgreSQL)

```dart
// Dynamic only
where: ComparisonOperator(
  column: 'email',
  value: {'$iRegexp': '^[A-Z]+@EXAMPLE\\.COM$'},
)
```

### Case-Insensitive NOT REGEXP (PostgreSQL)

```dart
// Dynamic only
where: ComparisonOperator(
  column: 'email',
  value: {'$notIRegexp': '^TEST@'},
)
```

## Other Operators

### Column Reference

Reference another column in comparisons:

```dart
// Dynamic only
where: ComparisonOperator(
  column: 'id',
  value: {'$col': 'users.email'}, // Compare id with email column
)
```

### Full-Text Search (PostgreSQL)

```dart
// Dynamic only
where: ComparisonOperator(
  column: 'content',
  value: {'$match': 'search term'},
)
```

## Operator Precedence

Operators are evaluated in this order:

1. Parentheses (when using nested `and`/`or`)
2. NOT
3. Comparison operators (gt, lt, eq, etc.)
4. AND
5. OR

Use parentheses (via nested `and`/`or`) to control evaluation order:

```dart
// (A OR B) AND C
where: and([
  or([
    equal('email', 'user1@example.com'),
    equal('email', 'user2@example.com'),
  ]),
  equal('active', true),
])
```

## Database-Specific Operators

Some operators are database-specific:

- **PostgreSQL**: `iLike`, `notILike`, `regexp`, `notRegexp`, `iRegexp`, `notIRegexp`, `match`
- **MySQL/MariaDB**: Most operators are supported, but regex operators differ

## Complete Examples

### Complex Query with Multiple Operators

```dart
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.gt(1)
      .and(q.email.like('%@example.com'))
      .or(q.firstName.eq('John'))
      .and(q.lastName.isNotNull()),
    order: [[q.id, 'DESC']],
    limit: 10,
  ),
);
```

### Using ComparisonOperator for Advanced Cases

```dart
var users = await Users.instance.findAll(
  Query(
    where: ComparisonOperator(
      column: 'age',
      value: {
        '$gte': 18,
        '$lte': 65,
      },
    ),
  ),
);
```

### Combining Multiple Conditions

```dart
var users = await Users.instance.findAll(
  Query(
    where: and([
      or([
        equal('email', 'user1@example.com'),
        equal('email', 'user2@example.com'),
      ]),
      ComparisonOperator(
        column: 'id',
        value: {'$gt': 10},
      ),
      not([
        equal('deleted', true),
      ]),
    ]),
  ),
);
```

## Next Steps

- Learn about [Typed Queries](./typed-queries.md) for type-safe operator usage
- See [Dynamic Queries](./dynamic-queries.md) for string-based operators
- Check out [Examples](./examples.md) for operator usage patterns
