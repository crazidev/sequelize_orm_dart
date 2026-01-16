---
sidebar_position: 3
---

# Using Associations

## Finding Records with Associations

To load associated records, use the `include` parameter. This parameter accepts a callback that gives you access to an "Include Builder" for the model.

### Basic Syntax

Use the generated methods on the include builder (like `.post()` or `.posts()`) to include associations.

```dart
// Single association
final user = await User.instance.findOne(
  where: User.instance.id.equals(1),
  include: (u) => [
    // highlight-next-line
    u.post(), // Includes the 'post' association
  ],
);

// Multiple associations
final user = await User.instance.findOne(
  where: User.instance.id.equals(1),
  include: (u) => [
    // highlight-start
    u.post(),
    u.posts(),
    // highlight-end
  ],
);
```

> **Note**: These methods (like `u.post`) are generated based on your association definitions (e.g., `@HasOne(..., as: 'post')`). If an association is not defined in the model, the method will not be available.

### Filtering Included Records

You can filter associated records by passing options to the include method.

```dart
final user = await User.instance.findOne(
  where: User.instance.id.equals(1),
  include: (u) => [
    // Include the 'post' association where post.id is 1
    // highlight-start
    u.post(
      where: (p) => p.id.eq(1),
    ),
    // highlight-end
  ],
);
```

### Using IncludeBuilder

For more dynamic or complex scenarios, you can manually create an `IncludeBuilder`:

```dart
// Manually create an include builder for the 'post' association
// highlight-next-line
var postInclude = IncludeBuilder<$Post>(association: 'post');

final user = await User.instance.findOne(
  include: (u) => [
    // Use the manual builder
    // highlight-start
    postInclude.copyWith(
      where: (p) => p.title.like('%News%'),
    ),
    // highlight-end
  ],
);
```

## Nested Associations

You can nest includes to load deep relationships (associations of associations).

```dart
// User -> Posts -> Comments
final user = await User.instance.findOne(
  where: User.instance.id.equals(1),
  include: (u) => [
    u.posts(
      include: (p) => [
        // highlight-next-line
        p.comments(), // Assuming Post has @HasMany(Comment)
      ],
    ),
  ],
);
```
