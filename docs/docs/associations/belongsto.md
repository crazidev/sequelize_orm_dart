---
sidebar_position: 3
---

# belongsTo

The `belongsTo` association creates a relationship where the **source model holds the foreign key** that points to the target model.

In Sequelize terms, `belongsTo` is the “child → parent” side of the association. It is commonly paired with `hasOne` or `hasMany` on the other model.

## Basic Example

```dart
@Table(tableName: 'posts')
abstract class Post {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  static PostModel get model => PostModel();
}

@Table(tableName: 'post_details')
abstract class PostDetails {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  // Foreign key column on the source model
  @ColumnName('post_id')
  DataType post_id = DataType.INTEGER;

  // Child -> Parent association
  @BelongsTo(Post, foreignKey: 'post_id', as: 'post')
  Post? post;

  static PostDetailsModel get model => PostDetailsModel();
}
```

## Options

### `foreignKey`

The foreign key column **on the source model**.

Example:

```dart
@BelongsTo(Post, foreignKey: 'post_id')
Post? post;
```

### `as`

The association alias used by Sequelize (and by include helpers).

Example:

```dart
@BelongsTo(Post, as: 'post')
Post? post;
```

### `targetKey`

By default, Sequelize references the target model’s primary key. You can override that by providing `targetKey`.

Example:

```dart
@BelongsTo(Post, foreignKey: 'post_id', targetKey: 'id')
Post? post;
```

Important note: If `targetKey` is the default (`'id'`), Sequelize already treats it as implicit. In our current generator we avoid explicitly sending `targetKey: 'id'` during association wiring because Sequelize may auto-create the inverse `belongsTo` when a `hasOne/hasMany` exists, and explicit default options can make the association “not reconcilable”.

## Eager loading (include)

Generated models provide a type-safe include helper for belongsTo, the same way as `hasOne` and `hasMany`:

```dart
final details = await PostDetails.model.findOne(
  where: (c) => c.id.eq(1),
  include: (i) => [
    // highlight-next-line
    i.post(),
  ],
);

print(details?.post?.toJson());
```

Nested includes work as expected:

```dart
final details = await PostDetails.model.findOne(
  where: (c) => c.id.eq(1),
  include: (i) => [
    i.post(
      include: (postIncl) => [
        postIncl.user(),
      ],
    ),
  ],
);
```

## Nested create

When creating an instance with nested association data, Sequelize requires the `include` tree to describe **all nested levels** you want it to accept.

Sequelize Dart’s generator builds the include tree for create calls so multi-level nested create payloads are not ignored.

Example (PostDetails → Post → User):

```dart
final details = await PostDetails.model.create(
  CreatePostDetails(
    post: CreatePost(
      title: 'Hello',
      user: CreateUsers(
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
      ),
    ),
  ),
);
```

## Instance methods (planned)

Sequelize supports instance methods for `belongsTo` such as `getX`, `setX`, and `createX` (see the Sequelize docs for details). We have generator code prepared for these methods, but **but we're currently testing** until the API is perfect.

