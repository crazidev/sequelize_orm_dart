---
sidebar_position: 2
---

# hasMany

The `hasMany` association creates a one-to-many relationship where one instance of the source model has many instances of the target model.

## Basic Example

```dart
@Table(tableName: 'users')
class User {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static UserModel get model => UserModel();
}

@Table(tableName: 'posts')
class Post {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @ColumnName('user_id')
  DataType userId = DataType.INTEGER;

  DataType title = DataType.STRING;

  static PostModel get model => PostModel();
}
```

## Usage

```dart
// Find user with all their posts
final user = await User.model.findOne(
  where: User.model.id.equals(1),
  include: (u) => [
    // highlight-next-line
    u.posts(),
  ],
);

print('User ID: ${user?.id}');
print('Posts: ${user?.posts?.length}');
for (final post in user?.posts ?? []) {
  print('  - ${post.title}');
}
```
