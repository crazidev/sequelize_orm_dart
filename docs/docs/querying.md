---
sidebar_position: 1
---

# Querying Basics

Sequelize Dart provides a powerful, type-safe API for querying your database. Most operations use callback functions to ensure type safety and leverage your generated model definitions.

## Finding Records

### findAll

Retrieve multiple records matching your criteria.

```dart
// Find all users
final users = await Users.model.findAll();

// Find users with conditions
final activeUsers = await Users.model.findAll(
  where: (user) => user.email.isNotNull(),
  limit: 10,
);

// Find with associations
final usersWithPosts = await Users.model.findAll(
  include: (include) => [include.posts()],
);
```

### findOne

Retrieve a single record.

```dart
// Find a user by email
final user = await Users.model.findOne(
  where: (user) => user.email.equals('user@example.com'),
);

// Find with associations
final userWithPost = await Users.model.findOne(
  where: (user) => user.id.equals(1),
  include: (include) => [include.post()],
);
```

## Creating Records

### Create

Creates a new record in the database.

```dart
// Create using the generated helper class (Recommended)
final user = await Users.model.create(
  CreateUsers(
    email: 'user@example.com',
    firstName: 'John',
    lastName: 'Doe',
    // Support for creating with associations
    post: CreatePost(
      title: 'First Post',
      content: 'Hello World',
    ),
  ),
);
```

## Updating Records

### Update

Updates records matching the query conditions.

```dart
// Update with named parameters
final affected = await Users.model.update(
  firstName: 'Jane',
  where: (user) => user.email.equals('user@example.com'),
);

// Update multiple fields
await Users.model.update(
  lastName: 'Smith',
  firstName: 'Jane',
  where: (user) => user.id.equals(1),
);
```

### Updating Instances

You can also update a model instance directly.

```dart
final user = await Users.model.findByPk(1);

if (user != null) {
  user.firstName = 'Updated Name';
  await user.save();
}
```

---

## Query Conditions (`where`)

Use the `where` callback to build type-safe conditions using column extensions.

### Comparison Operators

```dart
// Equals
(user) => user.email.equals('user@example.com')

// Not equals
(user) => user.email.notEquals('user@example.com')

// Greater than / Less than
(user) => user.age.gt(18)
(user) => user.age.lte(65)

// Between
(user) => user.age.between(18, 65)

// In / Not In
(user) => user.status.in_(['active', 'pending'])
(user) => user.status.notIn(['banned'])
```

### Null Checks

```dart
(user) => user.deletedAt.isNull()
(user) => user.email.isNotNull()
```

### String Operators

```dart
// Like (Case-sensitive)
(user) => user.username.like('admin%')

// iLike (Case-insensitive - Postgres only)
(user) => user.username.iLike('admin%')

// Not Like
(user) => user.username.notLike('%test%')
```

### Logical Combinations (AND, OR, NOT)

You can combine multiple conditions using `and`, `or`, and `not`.

```dart
// AND (Implicit or explicit)
Users.model.findAll(
  where: (user) => and([
    user.age.gte(18),
    user.isActive.equals(true),
  ]),
);

// OR
Users.model.findAll(
  where: (user) => or([
    user.role.equals('admin'),
    user.role.equals('moderator'),
  ]),
);

// NOT
Users.model.findAll(
  where: (user) => not([
    user.status.equals('banned'),
  ]),
);

// Nested Combinations
Users.model.findAll(
  where: (user) => and([
    user.email.isNotNull(),
    or([
      user.role.equals('admin'),
      user.permissions.contains('superuser'),
    ]),
  ]),
);
```

### Advanced Filtering

#### Casting

Cast columns using the `::` syntax within a `Column` definition.

```dart
Users.model.findOne(
  where: (user) => and([
    const Column('id::text').eq('1'),
  ]),
);
```

#### Referencing Associated Models

Filter using columns from associated models in the top-level `where` clause using the `$` syntax.

```dart
Users.model.findOne(
  include: (include) => [include.post()],
  where: (user) => and([
    const Column('$post.views$').gt(100),
  ]),
);
```

---

## Sorting (`order`)

Sort results using simple arrays, `Sequelize.col`, or `Sequelize.literal`.

```dart
Users.model.findAll(
  order: [
    // Simple ordering: [column, direction]
    ['lastName', 'ASC'],

    // Associated model column
    ['post', 'created_at', 'DESC'],

    // Using Sequelize.col
    Sequelize.col('username'),

    // Using Sequelize.fn (e.g. sort by max value)
    [Sequelize.fn('max', Sequelize.col('score')), 'DESC'],

    // Random ordering
    Sequelize.random(),
  ],
);
```

---

## Pagination (`limit`, `offset`)

Control the number of records returned.

```dart
// Get 2nd page of 20 users
final users = await Users.model.findAll(
  limit: 20,
  offset: 20, // Skip first 20
  order: [['id', 'ASC']],
);
```

---

## Selecting Attributes

Specify which columns to include or exclude in the result.

```dart
// Include specific columns
Users.model.findAll(
  attributes: QueryAttributes.include(['id', 'email', 'firstName']),
);

// Exclude sensitive columns
Users.model.findAll(
  attributes: QueryAttributes.exclude(['password', 'secretToken']),
);
```

---

## Aggregations & Utilities

Perform calculations directly on the database.

### Count

Count records matching the query conditions.

```dart
// Count all records
final totalCount = await Users.model.count();

// Count with conditions
final activeCount = await Users.model.count(
  where: (user) => user.isActive.eq(true),
);
```

### Sum, Max, Min

Calculate aggregate values with optional where clauses.

```dart
// Sum - all records
final totalLikes = await Post.model.sum((post) => post.likes);

// Sum - with where clause
final totalViews = await Post.model.sum(
  (post) => post.views,
  where: (post) => post.userId.eq(1),
);

// Max - all records
final maxScore = await Users.model.max((user) => user.score);

// Max - with where clause
final maxViews = await Post.model.max(
  (post) => post.views,
  where: (post) => post.userId.eq(1),
);

// Min - all records
final minAge = await Users.model.min((user) => user.age);

// Min - with where clause
final minViews = await Post.model.min(
  (post) => post.views,
  where: (post) => post.views.gt(0),
);
```

### Increment & Decrement

Increment or decrement numeric column values. These methods are only generated for models with numeric fields (int, double, num) and support where clauses.

```dart
// Increment a single field
await Post.model.increment(
  views: 5,
  where: (post) => post.id.eq(1),
);

// Increment multiple fields
await Post.model.increment(
  views: 10,
  likes: 2,
  where: (post) => post.userId.eq(1),
);

// Decrement a single field
await Post.model.decrement(
  views: 3,
  where: (post) => post.id.eq(2),
);

// Decrement with complex conditions
await Post.model.decrement(
  views: 1,
  where: (post) => and([
    post.userId.eq(1),
    post.views.gt(0),
  ]),
);
```

**Note:** Increment and decrement methods are only available for models that have numeric fields (int, double, num). Primary keys, auto-increment fields, and foreign keys are excluded.
