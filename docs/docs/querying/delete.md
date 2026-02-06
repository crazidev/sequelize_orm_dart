---
sidebar_position: 5
---

# Delete (Destroying Data)

Sequelize Dart provides several ways to delete records from your database, supporting both hard deletes (permanent removal) and soft deletes (marking as deleted while preserving data).

## Model.destroy() - Bulk Delete

The static `destroy` method removes records from the database that match the `where` condition.

### Basic Usage

```dart
// Delete all users with status 'inactive'
final deletedCount = await Users.model.destroy(
  where: (user) => user.status.eq('inactive'),
);

print('Deleted $deletedCount users');
```

### Soft Delete (Paranoid Models)

For models with paranoid mode enabled (have a `deletedAt` column), `destroy` performs a soft delete by setting the `deletedAt` timestamp instead of removing the record.

```dart
// Soft delete a user (sets deletedAt timestamp)
await Users.model.destroy(
  where: (user) => user.id.eq(123),
);

// The record still exists but won't appear in normal queries
final user = await Users.model.findOne(
  where: (u) => u.id.eq(123),
);
// user is null because soft-deleted records are excluded by default
```

### Hard Delete with force

To permanently delete records even on paranoid models, use the `force` option:

```dart
// Permanently delete a user, bypassing soft delete
await Users.model.destroy(
  where: (user) => user.id.eq(123),
  force: true,
);
```

### Options

| Option | Type | Description |
|--------|------|-------------|
| `where` | `Function` | Required. Callback to build the WHERE clause |
| `force` | `bool` | If `true`, performs hard delete even on paranoid models |
| `limit` | `int` | Maximum number of records to delete |
| `individualHooks` | `bool` | If `true`, runs hooks for each instance |

## Model.truncate() - Clear Table

The `truncate` method removes all records from a table. This is faster than deleting all records individually.

```dart
// Remove all records from the Users table
await Users.model.truncate();

// With options
await Users.model.truncate(
  cascade: true,          // Also truncate related tables
  restartIdentity: true,  // Reset auto-increment counters
);
```

### Options

| Option | Type | Description |
|--------|------|-------------|
| `cascade` | `bool` | Truncate dependent tables as well |
| `restartIdentity` | `bool` | Reset auto-increment sequences |
| `force` | `bool` | Force truncate even on paranoid models |

## Model.restore() - Restore Soft-Deleted Records

For paranoid models, you can restore soft-deleted records using the `restore` method:

```dart
// Restore a soft-deleted user
await Users.model.restore(
  where: (user) => user.id.eq(123),
);

// The record is now visible in normal queries again
final user = await Users.model.findOne(
  where: (u) => u.id.eq(123),
);
// user is not null
```

### Options

| Option | Type | Description |
|--------|------|-------------|
| `where` | `Function` | Required. Callback to build the WHERE clause |
| `limit` | `int` | Maximum number of records to restore |
| `individualHooks` | `bool` | If `true`, runs hooks for each instance |

## Sequelize-Level Operations

For operations across all models, use the Sequelize instance methods:

### sequelize.truncate()

Truncates all tables in the database:

```dart
// Truncate all tables
await sequelize.truncate(
  cascade: true,
  restartIdentity: true,
);
```

### sequelize.destroyAll()

Destroys all records from all models:

```dart
// Hard delete all records from all tables
await sequelize.destroyAll(force: true);
```

## Complete Example

```dart
// Create test data
final user = await Users.model.create(
  CreateUsers(
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
  ),
);

// Soft delete (paranoid model)
await Users.model.destroy(
  where: (u) => u.id.eq(user.id),
);

// Record not found in normal queries
final notFound = await Users.model.findOne(
  where: (u) => u.id.eq(user.id),
);
assert(notFound == null);

// But can be found with paranoid: false
final softDeleted = await Users.model.findOne(
  where: (u) => u.id.eq(user.id),
  paranoid: false,
);
assert(softDeleted != null);
assert(softDeleted.deletedAt != null);

// Restore the record
await Users.model.restore(
  where: (u) => u.id.eq(user.id),
);

// Record is visible again
final restored = await Users.model.findOne(
  where: (u) => u.id.eq(user.id),
);
assert(restored != null);
assert(restored.deletedAt == null);

// Hard delete (permanent)
await Users.model.destroy(
  where: (u) => u.id.eq(user.id),
  force: true,
);

// Record is completely gone
final gone = await Users.model.findOne(
  where: (u) => u.id.eq(user.id),
  paranoid: false,
);
assert(gone == null);
```
