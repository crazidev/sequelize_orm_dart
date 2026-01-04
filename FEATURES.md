# Sequelize Dart - Features

A Dart port of Sequelize.js ORM with type-safe query building.

## Quick Overview

| Feature                       | Status |
| ----------------------------- | ------ |
| PostgreSQL / MySQL / MariaDB  | ✅     |
| `findAll` / `findOne` queries | ✅     |
| All query operators           | ✅     |
| Type-safe query builder       | ✅     |
| Code generation               | ✅     |
| Create / Update / Delete      | ❌     |
| Associations                  | ❌     |
| Transactions                  | ❌     |
| Migrations                    | ❌     |

---

## ✅ What Works

### Connections

- PostgreSQL, MySQL, MariaDB
- Connection pooling
- SSL support
- SQL logging

### Queries

```dart
// Type-safe queries with generated query builders
Users.instance.findAll((u) => Query(
  where: and([
    u.id.gt(10),
    u.email.like('%@example.com'),
  ]),
  order: [['createdAt', 'DESC']],
  limit: 10,
));
```

### Query Options

`where` · `order` · `limit` · `offset` · `attributes`

### Operators

| Category         | Operators                                                                     |
| ---------------- | ----------------------------------------------------------------------------- |
| **Comparison**   | `eq`, `ne`, `gt`, `gte`, `lt`, `lte`                                          |
| **Logical**      | `and`, `or`, `not`                                                            |
| **Null/Boolean** | `isNull`, `isNotNull`, `isTrue`, `isFalse`                                    |
| **Range**        | `between`, `notBetween`                                                       |
| **List**         | `in_`, `notIn`, `any`, `all`                                                  |
| **String**       | `like`, `notLike`, `startsWith`, `endsWith`, `substring`, `iLike`, `notILike` |
| **Regex**        | `regexp`, `notRegexp`, `iRegexp`, `notIRegexp`                                |
| **Other**        | `col`, `match`                                                                |

### Model Definition

```dart
@Table(tableName: 'users')
class Users {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true, autoIncrement: true)
  dynamic id;

  @ModelAttributes(name: 'email', type: DataType.STRING)
  dynamic email;

  static $Users get instance => $Users();
}
```

### Data Types

`STRING` · `INTEGER` · `BIGINT` · `FLOAT` · `DOUBLE` · `BOOLEAN` · `DATE` · `JSON` · `JSONB`

---

## ❌ Not Yet Implemented

- **CRUD**: `create`, `update`, `destroy`, `findByPk`, `count`, `bulkCreate`
- **Associations**: `hasOne`, `belongsTo`, `hasMany`, `belongsToMany`
- **Transactions**: Transaction support
- **Migrations**: Schema migrations
- **Raw queries**: `sequelize.query()`
- **Hooks**: Lifecycle events

## Implementated

- **Functions**: `sequelize.fn()`, `sequelize.literal()`
- **Nested Sorting**: Support for `hoistIncludeOptions` to sort by included models

---

## Testing

All operators have integration tests:

```bash
cd example && dart test test/operators/
```

Tests verify SQL output for: `eq`, `ne`, `gt`, `gte`, `lt`, `lte`, `between`, `in_`, `notIn`, `like`, `iLike`, `regexp`, `isNull`, `and`, `or`, `not`, and more.
