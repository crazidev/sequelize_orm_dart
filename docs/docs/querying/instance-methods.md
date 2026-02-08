---
sidebar_position: 4
---

# Instance Methods

Instances in Sequelize Dart come with several helpful methods to manage their state.

## save()

Persists the current state of the instance to the database. If the instance was retrieved from the database, it performs an `UPDATE`. If it's a new instance (not yet created), it performs an `INSERT`.

```dart
user.firstName = 'New Name';
await user.save();
```

## reload()

Refreshes the instance with the latest data from the database. This is useful if you suspect the data might have changed elsewhere or if you want to reset local changes.

```dart
final user = await Users.model.findOne(where: (u) => u.id.eq(1));

// ... some operations ...

// Re-fetch data from DB
await user.reload();
```

## destroy()

Deletes the instance from the database. For paranoid models (with `deletedAt` column), this performs a soft delete by default.

```dart
final user = await Users.model.findOne(where: (u) => u.id.eq(1));

// Soft delete (for paranoid models)
await user?.destroy();

// Hard delete (permanent removal)
await user?.destroy(force: true);
```

### Options

| Option | Type | Description |
|--------|------|-------------|
| `force` | `bool` | If `true`, performs a hard delete even on paranoid models |
| `hooks` | `bool` | If `false`, skips lifecycle hooks |

## restore()

Restores a soft-deleted instance. This is only available for paranoid models (models with a `deletedAt` column).

```dart
// First, find the soft-deleted user
final user = await Users.model.findOne(
  where: (u) => u.id.eq(1),
  paranoid: false,  // Include soft-deleted records
);

// Restore the user
await user?.restore();

// The user is now visible in normal queries
final restored = await Users.model.findOne(where: (u) => u.id.eq(1));
print(restored != null);  // true
```

### Options

| Option | Type | Description |
|--------|------|-------------|
| `hooks` | `bool` | If `false`, skips lifecycle hooks |
| `logging` | `bool` | If `false`, disables logging for this operation |

## Complete Example

```dart
// Create a user
final user = await Users.model.create(
  CreateUsers(email: 'test@example.com', firstName: 'Test'),
);

// Modify and save
user.firstName = 'Updated';
await user.save();

// Reload from database
await user.reload();

// Soft delete
await user.destroy();

// Find and restore
final deleted = await Users.model.findOne(
  where: (u) => u.id.eq(user.id),
  paranoid: false,
);
await deleted?.restore();

// Permanently delete
await deleted?.destroy(force: true);
```
