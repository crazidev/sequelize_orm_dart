Associations define relationships between models, enabling you to work with
related data efficiently via eager loading and foreign key management.

## Association Types

| Annotation    | Relationship | Example                    |
| ------------- | ------------ | -------------------------- |
| `@HasOne`     | One-to-one   | User has one Profile       |
| `@HasMany`    | One-to-many  | User has many Posts        |
| `@BelongsTo`  | Child-parent | Post belongs to User       |

## Defining Associations

```dart
@Table(tableName: 'users', underscored: true)
class Users {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  DataType email = DataType.STRING;

  @HasMany(Post, foreignKey: 'user_id', as_: 'posts')
  DataType posts = DataType.INTEGER;

  @HasOne(Profile, foreignKey: 'user_id', as_: 'profile')
  DataType profile = DataType.INTEGER;

  static UsersModel get model => UsersModel();
}

@Table(tableName: 'posts', underscored: true)
class Post {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  DataType title = DataType.STRING;
  DataType content = DataType.TEXT;

  @BelongsTo(Users, foreignKey: 'user_id', as_: 'user')
  DataType user = DataType.INTEGER;

  static PostModel get model => PostModel();
}
```

## Eager Loading

Fetch related data in a single query using the type-safe `include` option.

```dart
// Load users with their posts
final users = await Users.model.findAll(
  include: (u) => [u.posts()],
);

// Load user with profile and posts (nested)
final user = await Users.model.findOne(
  where: (u) => u.id.eq(1),
  include: (u) => [
    u.profile(),
    u.posts(
      where: (p) => p.title.like('%Dart%'),
      limit: 5,
    ),
  ],
);
```

## Inner Join (Required)

By default, Sequelize uses a LEFT OUTER JOIN. Set `required: true` for an
INNER JOIN — only returns records that have the association.

```dart
final usersWithPosts = await Users.model.findAll(
  include: (u) => [
    u.posts(required: true),
  ],
);
```

## Nested Eager Loading

Load associations of associations to any depth.

```dart
final users = await Users.model.findAll(
  include: (u) => [
    u.posts(
      include: (p) => [
        p.comments(),  // Load comments for each post
      ],
    ),
  ],
);
```

## Separate Queries

For `@HasMany` associations, use `separate: true` to run a separate query
instead of a JOIN. This avoids Cartesian product issues with multiple
one-to-many includes.

```dart
final users = await Users.model.findAll(
  include: (u) => [
    u.posts(separate: true, limit: 10),
  ],
);
```

## BelongsTo Mixin Methods

Generated `BelongsTo` associations include helper methods:

```dart
// Get the associated parent
final user = await post.getUser();

// Set a new parent
await post.setUser(anotherUser);

// Create a new parent
final newUser = await post.createUser(
  CreateUsers(email: 'new@example.com', firstName: 'New'),
);
```
