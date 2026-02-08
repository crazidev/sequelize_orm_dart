---
sidebar_position: 4
---

# Timestamps

By default, Sequelize Dart automatically adds the attributes `createdAt` and `updatedAt` to every model, using the data type `DATE`. These attributes are automatically managed - whenever you use Sequelize Dart to create or update something, those attributes will be set correctly.

The `createdAt` attribute will contain the timestamp representing the moment of creation, and the `updatedAt` will contain the timestamp of the latest update.

:::info Important Note
The value of these attributes are updated by Sequelize in JavaScript (i.e. not done with SQL triggers). This means that direct SQL queries (for example queries performed without Sequelize Dart by any other means) will not cause these attributes to be updated automatically.
:::

## Enabling Timestamps

By default, timestamps are enabled. When `timestamps: true`, Sequelize Dart automatically adds `createdAt` and `updatedAt` attributes:

```dart
@Table(
  timestamps: true,  // Automatically adds createdAt and updatedAt
)
class Users {}
```

You can explicitly enable with default column names using `TimestampOption.enabled()`:

```dart
@Table(
  timestamps: true,
  createdAt: TimestampOption.enabled(),
  updatedAt: TimestampOption.enabled(),
)
class Users { }
```

## Custom Timestamp Column Names

Use `TimestampOption.custom()` to specify custom column names for the database. This changes the **column name** in the database while keeping the attribute names in Dart code:

```dart
@Table(
  timestamps: true,
  createdAt: TimestampOption.custom('created_at'),
  updatedAt: TimestampOption.custom('updated_at'),
)
class Users {
  // Attributes are still accessed as createdAt and updatedAt in Dart
  // But stored as created_at and updated_at in the database
}
```

## Disabling Individual Timestamps

Use `TimestampOption.disabled()` to disable individual timestamps while keeping others enabled:

```dart
@Table(
  tableName: 'users',
  timestamps: true,
  createdAt: TimestampOption.enabled(),
  updatedAt: TimestampOption.disabled(),  // Disable updatedAt only
)
class Users {
  // Only createdAt will be automatically managed
}
```

## Disabling All Timestamps

Set `timestamps: false` to disable all automatic timestamps:

```dart
@Table(
  tableName: 'users',
  timestamps: false,  // No automatic timestamps
)
class Users {}
```

## TimestampOption API

The `TimestampOption` class provides three constructors for managing timestamps:

- **`TimestampOption.enabled()`** - Enable timestamp with default column name
- **`TimestampOption.custom('column_name')`** - Enable timestamp with custom column name
- **`TimestampOption.disabled()`** - Disable the timestamp
