---
sidebar_position: 5
---

# Association Options

## foreignKey

Specify the foreign key column name:

```dart
@HasOne(Post, foreignKey: 'userId', as: 'post')
Post? post;

// If not specified, Sequelize infers: 'userId' from 'Users' -> 'user_id'
```

## as (Alias)

Give the association an alias:

```dart
@HasOne(Post, foreignKey: 'userId', as: 'mainPost')
Post? mainPost;

// Use the alias when querying
final user = await Users.instance.findOne(
  include: [Users.instance.mainPost],
);
```

## sourceKey

Specify the source key (the key in the source model):

```dart
@HasOne(Post,
  foreignKey: 'userId',
  sourceKey: 'id',  // Use 'id' from Users (default)
  as: 'post',
)
Post? post;
```
