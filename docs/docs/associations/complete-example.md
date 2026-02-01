---
sidebar_position: 6
---

# Complete Example

Here's a complete example with multiple associations:

```dart
@Table(tableName: 'users')
class User {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @Validate.IsEmail()
  DataType email = DataType.STRING;

  // One-to-one: User has one profile
  @HasOne(Profile, foreignKey: 'userId', as: 'profile')
  Profile? profile;

  // One-to-many: User has many posts
  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static UserModel get model => UserModel();
}

@Table(tableName: 'profiles')
class Profile {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @ColumnName('user_id')
  DataType userId = DataType.INTEGER;

  DataType bio = DataType.TEXT;

  // Child to one: Belongs to one Parent
  @BelongsTo(Post, foreignKey: 'user_id', as: 'post')
  User? user;

  static ProfileModel get model => ProfileModel();
}

@Table(tableName: 'posts')
class Post {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @ColumnName('user_id')
  DataType userId = DataType.INTEGER;

  // Child to one: Belongs to one Parent
  @BelongsTo(Post, foreignKey: 'user_id', as: 'post')
  User? user;

  DataType title = DataType.STRING;

  static PostModel get model => PostModel();
}

// Usage
Future<void> example() async {
  // Initialize models
  await sequelize.initialize(
    models: [
      User.model,
      Profile.model,
      Post.model,
    ],
  );

  // Find user with all associations
  final user = await User.model.findOne(
    where: User.model.id.equals(1),
    include: (u) => [
      u.profile,
      u.posts,
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
