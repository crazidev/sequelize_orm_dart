---
sidebar_position: 1
---

# hasOne

The `hasOne` association creates a one-to-one relationship where one instance of the source model belongs to one instance of the target model.

## Basic Example

```dart
@Table(tableName: 'users')
class Users {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;

  @HasOne(Post, foreignKey: 'userId', as: 'post')
  Post? post;

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
// Find user with their post
final user = await Users.instance.findOne(
  where: Users.instance.id.equals(1),
  include: [Users.instance.post],
);

print('User: ${user?.email}');
print('Post: ${user?.post?.title}');
```
