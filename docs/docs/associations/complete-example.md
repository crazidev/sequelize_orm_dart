---
sidebar_position: 6
---

# Complete Example

Here's a complete example with multiple associations:

```dart
@Table(tableName: 'users')
class Users {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;

  @ModelAttributes(name: 'email', type: DataType.STRING)
  dynamic email;

  // One-to-one: User has one profile
  @HasOne(Profile, foreignKey: 'userId', as: 'profile')
  Profile? profile;

  // One-to-many: User has many posts
  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static $Users get instance => $Users();
}

@Table(tableName: 'profiles')
class Profile {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;

  @ModelAttributes(name: 'user_id', type: DataType.INTEGER)
  dynamic userId;

  @ModelAttributes(name: 'bio', type: DataType.TEXT)
  dynamic bio;

  static $Profile get instance => $Profile();
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

// Usage
Future<void> example() async {
  // Initialize models
  await sequelize.initialize(
    models: [
      Users.instance,
      Profile.instance,
      Post.instance,
    ],
  );

  // Find user with all associations
  final user = await Users.instance.findOne(
    where: Users.instance.id.equals(1),
    include: [
      Users.instance.profile,
      Users.instance.posts,
    ],
  );

  print('User: ${user?.email}');
  print('Bio: ${user?.profile?.bio}');
  print('Posts: ${user?.posts?.length}');
}
```

## Best Practices

1. **Always initialize models with associations**: Make sure all related models are included in `sequelize.initialize()`.

2. **Use eager loading**: Load associations when you know you'll need them to avoid N+1 queries.

3. **Use aliases for clarity**: When a model has multiple associations to the same target, use aliases to distinguish them.

4. **Define foreign keys explicitly**: While Sequelize can infer foreign key names, being explicit makes your code clearer.
