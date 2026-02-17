---
sidebar_position: 10
---

# Enum Querying

Sequelize Dart provides a powerful, type-safe API for querying `ENUM` columns.

## Generated Enums

When you define an `ENUM` column in your model, the generator creates a dedicated Dart `enum` for it.

```dart
@Table()
abstract class Users {
  DataType status = DataType.ENUM(['active', 'inactive', 'pending']);
}
```

This generates:

```dart
enum UsersStatus {
  active('active'),
  inactive('inactive'),
  pending('pending');

  final String value;
  const UsersStatus(this.value);
}
```

## Query Accessors

Enum columns have a multi-layered query API to balance descriptiveness and conciseness.

### 1. Prefix Shortcuts

By applying the `@EnumPrefix` annotation, you can generate direct property shortcuts on the column wrapper.

```dart
@EnumPrefix('is', 'not')
DataType status = DataType.ENUM(['active', 'inactive', 'pending']);
```

This allows for very expressive queries:

```dart
// Equality shortcuts
(u) => u.status.isActive
(u) => u.status.isInactive

// Negation shortcuts
(u) => u.status.notActive
(u) => u.status.notPending
```

### 2. Grouped Access (is / not)

To avoid cluttering the top-level autocomplete of your column, all enum values are also available under `is` and `not` (or your custom prefixes).

```dart
// Grouped equality
(u) => u.status.is.active
(u) => u.status.is.inactive

// Grouped negation
(u) => u.status.not.active
(u) => u.status.not.pending
```

:::info Alias for Groupers
Standard `eq` and `not` aliases are always available regardless of your `@EnumPrefix` configuration.
:::

### 3. Null Checks

Null checks are implemented as functions, matching the standard `Column` API.

```dart
(u) => u.status.isNull()
(u) => u.status.isNotNull()
```

### 4. Type-Safe Methods

You can also use the `.eq()` and `.not()` methods with the generated enum, raw strings, or `null`.

```dart
// Using generated enum
(u) => u.status.eq(UsersStatus.active)

// Using raw string
(u) => u.status.not('inactive')

// Using null (same as isNull() / isNotNull())
(u) => u.status.eq(null)
(u) => u.status.not(null)
```

## Summary Table

| Syntax | Description | Example |
|---|---|---|
| **Shortcuts** | Direct properties (via `@EnumPrefix`) | `u.status.isActive` |
| **Grouped** | Nested under `eq`/`not` | `u.status.eq.active` |
| **Null** | Function-based checks | `u.status.isNull()` |
| **Methods** | Type-safe method calls | `u.status.eq(UsersStatus.active)` |
| **Negation** | Negated comparisons | `u.status.not.active` |
