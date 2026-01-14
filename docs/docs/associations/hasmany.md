---
sidebar_position: 2
---

# hasMany

The `hasMany` association creates a one-to-many relationship where one instance of the source model has many instances of the target model.

## Basic Example

```dart
@Table(tableName: 'users')
class Users {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;

  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static $Users get instance => $Users();
}

@Table(tableName: 'posts')
class Post {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;

  @ModelAttributes(name: 'user_id', type: DataType.INTEGER)
  dynamic userId;

  @ModelAttributes(name: 'title', type: DataType.STRING)
  dynamic title;

  static $Post get instance => $Post();
}
```

## Usage

```dart
// Find user with all their posts
final user = await Users.instance.findOne(
  where: Users.instance.id.equals(1),
  include: [Users.instance.posts],
);

print('User: ${user?.email}');
print('Posts: ${user?.posts?.length}');
for (final post in user?.posts ?? []) {
  print('  - ${post.title}');
}
```
