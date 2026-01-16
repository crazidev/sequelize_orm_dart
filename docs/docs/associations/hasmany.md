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

  static $User get instance => $User();
}

@Table(tableName: 'posts')
class Post {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @ColumnName('user_id')
  DataType userId = DataType.INTEGER;

  DataType title = DataType.STRING;

  static $Post get instance => $Post();
}
```

## Usage

```dart
// Find user with all their posts
final user = await User.instance.findOne(
  where: User.instance.id.equals(1),
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
