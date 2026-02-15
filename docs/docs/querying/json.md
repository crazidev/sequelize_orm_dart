---
sidebar_position: 5.5
---

# JSON Querying

This guide covers how to define JSON columns, what data they hold, and how to query them using the fluent `JsonColumn` API.

## Defining JSON Columns

Use `DataType.JSON` or `DataType.JSONB` with an optional `type:` parameter to control the generated Dart type.

```dart
@Table(underscored: true)
abstract class Users {
  // Array JSON — stores a list of values
  DataType tags = DataType.JSONB(type: List<String>);
  DataType scores = DataType.JSONB(type: List<int>);

  // Object JSON — stores key/value pairs (default when no type: is given)
  DataType metadata = DataType.JSONB;
}
```

### Supported types

**Array JSON:**

| Definition | Dart type |
|---|---|
| `DataType.JSONB(type: List<String>)` | `List<String>?` |
| `DataType.JSONB(type: List<int>)` | `List<int>?` |
| `DataType.JSONB(type: List<double>)` | `List<double>?` |
| `DataType.JSONB(type: List<bool>)` | `List<bool>?` |
| `DataType.JSONB(type: List<dynamic>)` | `List<dynamic>?` |
| `DataType.JSONB(type: List<Map<String, dynamic>>)` | `List<Map<String, dynamic>>?` |

**Object JSON:**

| Definition | Dart type |
|---|---|
| `DataType.JSONB` _(default)_ | `Map<String, dynamic>?` |
| `DataType.JSONB(type: Map<String, String>)` | `Map<String, String>?` |
| `DataType.JSONB(type: Map<String, int>)` | `Map<String, int>?` |
| `DataType.JSONB(type: Map<String, double>)` | `Map<String, double>?` |
| `DataType.JSONB(type: Map<String, bool>)` | `Map<String, bool>?` |

:::tip JSON vs JSONB
`JSONB` stores data in a binary format and supports indexing in PostgreSQL. Use `JSONB` for PostgreSQL and `JSON` for MySQL / other databases.

By default, Sequelize automatically normalizes JSON types (`normalizeJsonTypes: true`), so you can freely write `DataType.JSON` or `DataType.JSONB` and Sequelize converts them to the correct type for the connected database. See [Data Types — JSON vs JSONB](../models/data-types#supported-type-values) for details.
:::

## Example Data

All query examples below use the following user record as reference:

```dart
await Db.users.create(CreateUsers(
  email: 'john@example.com',
  firstName: 'John',
  tags: ['dart', 'flutter', 'sequelize'],
  scores: [95, 87, 100],
  metadata: {
    'role': 'admin',
    'level': 5,
    'active': true,
    'address': {
      'city': 'Berlin',
      'zip': '10115',
    },
  },
));
```

This produces the following JSON values in the database:

| Column | Value |
|---|---|
| `tags` | `["dart", "flutter", "sequelize"]` |
| `scores` | `[95, 87, 100]` |
| `metadata` | `{"role": "admin", "level": 5, "active": true, "address": {"city": "Berlin", "zip": "10115"}}` |

## Querying JSON Columns

JSON/JSONB columns are generated as `JsonColumn<T>`, where `T` is the Dart type (e.g., `JsonColumn<List<String>>` for array columns). This provides type-safe equality checks and a fluent API with three core methods:

| Method | Description | SQL operator |
|---|---|---|
| `.key('name')` | Navigate to a key in a JSON object | `->` |
| `.at(index)` | Navigate to an array element by index | `->` |
| `.unquote()` | Extract as text instead of JSON | `->>` |

---

### Accessing a top-level key

Use `.key()` to navigate into a JSON object:

```dart
// JSON: {"role": "admin", "level": 5, ...}
where: (u) => u.metadata.key('role').eq('admin')
```

:::caution `.unquote()` is for strings only
`.unquote()` uses the `->>` operator which extracts and removes JSON quotes, returning **plain text**. You should only use this if the value can only be a string.

Using `.unquote()` on non-string values (numbers, booleans, null) can produce unexpected results. On PostgreSQL, comparing extracted text to a number fails with `operator does not exist: text > integer`.
:::

### Accessing a nested key

Chain `.key()` calls to traverse nested objects:

```dart
// JSON: {"address": {"city": "Berlin", "zip": "10115"}}
where: (u) => u.metadata.key('address').key('city').eq('Berlin')
```

### Accessing an array element by index

Use `.at()` to access a specific position in a JSON array:

```dart
// JSON: ["dart", "flutter", "sequelize"]
where: (u) => u.tags.at(0).eq('dart')
```

```dart
// JSON: [95, 87, 100]
where: (u) => u.scores.at(0).eq(95)
```

### Comparing a numeric JSON value

```dart
// JSON: {"role": "admin", "level": 5, ...}
where: (u) => u.metadata.key('level').eq(5)
```

```dart
// JSON: [95, 87, 100]
where: (u) => u.scores.at(0).gt(50)
```

### Pattern matching on JSON text

Use `.unquote()` to access string operators like `.like()`, `.iLike()`, `.startsWith()`, etc:

```dart
// JSON: {"address": {"city": "Berlin", ...}}
where: (u) => u.metadata.key('address').key('city').unquote().like('%ber%')

// Case-insensitive (PostgreSQL)
where: (u) => u.metadata.key('address').key('city').unquote().iLike('%ber%')
```

### Null checks

```dart
// Users that have metadata set
where: (u) => u.metadata.isNotNull()

// Users that have no tags
where: (u) => u.tags.isNull()
```

### Array containment (PostgreSQL JSONB only)

Use `.contains()` to check if a JSON array contains specific values. This uses the PostgreSQL `@>` operator and **only works with JSONB columns on PostgreSQL**.

```dart
// JSON: ["dart", "flutter", "sequelize"]
// SQL:  "tags" @> '["dart"]'::jsonb
where: (u) => u.tags.contains(['dart'])
```

```dart
// Check for multiple values
where: (u) => u.tags.contains(['dart', 'flutter'])
```

:::warning PostgreSQL JSONB only
`.contains()` only works on PostgreSQL with JSONB columns. It will throw an error on MySQL.

For cross-database array comparison, use `.eq()` to compare the entire array:

```dart
// Cross-database: compare the full array
where: (u) => u.tags.eq(['dart', 'flutter', 'sequelize'])
```
:::

### Whole-column equality

Compare an entire JSON column to a value. The generic type parameter ensures type safety:

```dart
// tags is JsonColumn<List<String>> — .eq() expects List<String>
where: (u) => u.tags.eq(['dart', 'flutter', 'sequelize'])

// scores is JsonColumn<List<int>> — .eq() expects List<int>
where: (u) => u.scores.eq([95, 87, 100])

// metadata is JsonColumn<dynamic> — .eq() accepts anything
where: (u) => u.metadata.eq({'role': 'admin', 'level': 5})
```

---

## PostgreSQL vs MySQL Compatibility

| Operation | MySQL JSON | PG JSON | PG JSONB |
|---|---|---|---|
| `.eq()` on whole column | Works | Fails | Works |
| `.key('x').eq(...)` | Works | Fails | Works |
| `.at(0).eq('x')` | Works | Works | Works |
| `.contains([...])` | Fails | Fails | Works |

:::tip normalizeJsonTypes
By default (`normalizeJsonTypes: true`), Sequelize automatically converts `JSON` to `JSONB` on PostgreSQL and `JSONB` to `JSON` on MySQL. This means you can write your models once and they work across databases without code changes.
:::

## Combining JSON Conditions

JSON conditions compose with `and()`, `or()`, and `not()` like any other condition.

### AND

```dart
// Users with role=admin AND level=5
where: (u) => and([
  u.metadata.key('role').eq('admin'),
  u.metadata.key('level').eq(5),
])
```

### OR

```dart
// Users with role=admin OR role=moderator
where: (u) => or([
  u.metadata.key('role').eq('admin'),
  u.metadata.key('role').eq('moderator'),
])
```

### Mixing JSON and regular columns

```dart
// Users named "John" whose first tag is "dart"
where: (u) => and([
  u.firstName.eq('John'),
  u.tags.at(0).eq('dart'),
])
```

### Complex nested conditions

```dart
where: (u) => and([
  u.tags.at(0).eq('dart'),
  u.metadata.key('level').gt(3),
  or([
    u.metadata.key('role').eq('admin'),
    u.metadata.key('role').eq('moderator'),
  ]),
])
```

## Updating JSON Columns

Pass the new value directly to the `update` method:

```dart
await Db.users.update(
  tags: ['dart', 'flutter', 'sequelize', 'postgres'],
  metadata: {'role': 'superadmin', 'level': 10, 'active': true},
  where: (u) => u.id.eq(userId),
);
```

## Raw String Fallback

If you prefer, you can still use a raw `Column` with the Sequelize dot-notation path:

```dart
const Column('metadata.address.city').eq('Berlin')
const Column('tags[0]').eq('dart')
```

## API Reference

### `JsonColumn<T>`

The type parameter `T` controls what `.eq()` and `.ne()` accept. For example, `JsonColumn<List<String>>` expects a `List<String>`.

| Method | Returns | Description |
|---|---|---|
| `.key(name)` | `JsonPath` | Navigate to a key in the JSON object |
| `.at(index)` | `JsonPath` | Navigate to an array element by index |
| `.unquote()` | `JsonText` | Extract the whole column as text (`->>`) |
| `.eq(T)`, `.ne(T)` | `ComparisonOperator` | Compare the whole JSON value (type-safe) |
| `.contains(dynamic)` | `ComparisonOperator` | Array containment — PostgreSQL JSONB only |
| `.isNull()`, `.isNotNull()` | `ComparisonOperator` | Null checks |

### `JsonPath`

| Method | Returns | Description |
|---|---|---|
| `.key(name)` | `JsonPath` | Navigate deeper into a nested key |
| `.at(index)` | `JsonPath` | Navigate to an array element |
| `.unquote()` | `JsonText` | Switch from `->` to `->>` (text extraction) |
| `.eq()`, `.ne()`, `.gt()`, `.gte()`, `.lt()`, `.lte()` | `ComparisonOperator` | Comparison operators |
| `.isNull()`, `.isNotNull()` | `ComparisonOperator` | Null checks |

### `JsonText`

Returned by `.unquote()`. Operates on text extracted by `->>` and should only be used for **string comparisons**. For numeric or boolean comparisons, use `JsonPath` directly (without `.unquote()`).

| Method | Returns | Description |
|---|---|---|
| `.eq()`, `.ne()`, `.gt()`, `.gte()`, `.lt()`, `.lte()` | `ComparisonOperator` | Comparison operators |
| `.like()`, `.notLike()` | `ComparisonOperator` | Pattern matching |
| `.iLike()`, `.notILike()` | `ComparisonOperator` | Case-insensitive pattern matching (PostgreSQL) |
| `.startsWith()`, `.endsWith()`, `.substring()` | `ComparisonOperator` | String prefix/suffix/contains |
| `.isNull()`, `.isNotNull()` | `ComparisonOperator` | Null checks |
