---
sidebar_position: 9
---

# Paranoid Mode (Soft Deletes)

Paranoid mode enables soft deletes for your models. Instead of permanently removing records from the database, they are marked as deleted by setting a `deletedAt` timestamp. This allows you to preserve data history and recover deleted records if needed.

## Enabling Paranoid Mode

To enable paranoid mode, add a `deletedAt` column to your model using the `@Table` annotation:

```dart
@Table(
  underscored: true,
  deletedAt: TimestampOption.custom('deleted_at'),
)
abstract class Users {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  DataType email = DataType.STRING;

  @ColumnName('deleted_at')
  DataType deletedAt = DataType.DATE;

  static UsersModel get model => UsersModel();
}
```

When `deletedAt` is configured, Sequelize Dart automatically:
- Performs soft deletes instead of hard deletes when calling `destroy()`
- Excludes soft-deleted records from queries by default
- Enables the `restore()` method to recover deleted records

## How It Works

### Soft Delete

When you call `destroy()` on a paranoid model, the record is not removed. Instead, the `deletedAt` column is set to the current timestamp:

```dart
// This performs a soft delete
await Users.model.destroy(
  where: (u) => u.id.eq(123),
);

// The SQL executed is:
// UPDATE Users SET deleted_at = '2024-01-15 10:30:00' WHERE id = 123
```

### Automatic Filtering

By default, all queries automatically exclude soft-deleted records:

```dart
// This only returns users where deleted_at IS NULL
final activeUsers = await Users.model.findAll();

// Soft-deleted users are not included
```

## Querying Soft-Deleted Records

### Using paranoid: false

To include soft-deleted records in your queries, set `paranoid: false`:

```dart
// Include soft-deleted records
final allUsers = await Users.model.findAll(
  paranoid: false,
);

// Find a specific soft-deleted record
final deletedUser = await Users.model.findOne(
  where: (u) => u.id.eq(123),
  paranoid: false,
);

if (deletedUser?.deletedAt != null) {
  print('This user was deleted at ${deletedUser.deletedAt}');
}
```

### Eager Loading Soft-Deleted Associations

When using includes (eager loading), you can also fetch soft-deleted associated records:

```dart
final users = await Users.model.findAll(
  include: (i) => [
    // Include soft-deleted posts in the association
    i.posts(paranoid: false),
  ],
);
```

This is useful when you need to display a user's complete history, including deleted items.

## Restoring Records

Use the `restore()` method to recover soft-deleted records:

```dart
// Static method - restore by condition
await Users.model.restore(
  where: (u) => u.id.eq(123),
);

// Instance method - restore a specific instance
final user = await Users.model.findOne(
  where: (u) => u.id.eq(123),
  paranoid: false,
);
await user?.restore();
```

After restoration, the `deletedAt` column is set to `NULL` and the record appears in normal queries again.

## Hard Delete (Permanent)

To permanently delete a record on a paranoid model, use the `force` option:

```dart
// Permanently delete, bypassing soft delete
await Users.model.destroy(
  where: (u) => u.id.eq(123),
  force: true,
);

// Instance method with force
await user.destroy(force: true);
```

## Complete Workflow Example

```dart
// 1. Create a user
final user = await Users.model.create(
  CreateUsers(email: 'test@example.com', firstName: 'Test'),
);
print('Created user with ID: ${user.id}');

// 2. Soft delete the user
await Users.model.destroy(
  where: (u) => u.id.eq(user.id),
);
print('User soft deleted');

// 3. User not visible in normal queries
final notFound = await Users.model.findOne(
  where: (u) => u.id.eq(user.id),
);
print('Normal query finds user: ${notFound != null}'); // false

// 4. User visible with paranoid: false
final found = await Users.model.findOne(
  where: (u) => u.id.eq(user.id),
  paranoid: false,
);
print('Paranoid query finds user: ${found != null}'); // true
print('Deleted at: ${found?.deletedAt}');

// 5. Restore the user
await Users.model.restore(
  where: (u) => u.id.eq(user.id),
);
print('User restored');

// 6. User visible again
final restored = await Users.model.findOne(
  where: (u) => u.id.eq(user.id),
);
print('User visible after restore: ${restored != null}'); // true
print('Deleted at after restore: ${restored?.deletedAt}'); // null

// 7. Permanently delete
await Users.model.destroy(
  where: (u) => u.id.eq(user.id),
  force: true,
);
print('User permanently deleted');
```

## Best Practices

1. **Use paranoid mode for user-facing data**: Enable soft deletes for data that users might want to recover, like posts, comments, or user accounts.

2. **Consider storage implications**: Soft-deleted records still occupy database space. Implement a cleanup policy for old deleted records if needed.

3. **Index the deletedAt column**: Since queries filter by `deletedAt IS NULL`, indexing this column improves query performance.

4. **Be careful with unique constraints**: Soft-deleted records still exist in the database, so unique constraints need to account for them.
