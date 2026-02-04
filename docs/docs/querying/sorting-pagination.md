---
sidebar_position: 6
---

# Sorting & Pagination

## Sorting (`order`)

Sort results by one or more columns.

```dart
Users.model.findAll(
  order: [
    // Simple ordering: [column, direction]
    ['lastName', 'ASC'],
    ['createdAt', 'DESC'],

    // User Sequelize.col
    Sequelize.col('username'),

    // Random ordering
    Sequelize.random(),
  ],
);
```

## Pagination (`limit`, `offset`)

Control the number of records returned.

```dart
// Skip 20, take 20
Users.model.findAll(
  limit: 20,
  offset: 20,
);
```
