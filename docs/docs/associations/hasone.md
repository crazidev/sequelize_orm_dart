---
sidebar_position: 1
---

# hasOne

The `hasOne` association creates a one-to-one relationship where one instance of the source model belongs to one instance of the target model.

## Basic Example

```dart
@Table(tableName: 'users')
class User {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @HasOne(Post, foreignKey: 'userId', as: 'post')
  Post? post;

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
// Find user with their post
final user = await User.model.findOne(
  where: User.model.id.equals(1),
  include: (u) => [
    // highlight-next-line
    u.post(),
  ],
);

print('User ID: ${user?.id}');
print('Post: ${user?.post?.title}');
```
