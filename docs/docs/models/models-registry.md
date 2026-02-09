---
sidebar_position: 8
---

# Models Registry

The Models Registry Generator automatically creates a centralized registry class for accessing all your models. This feature significantly improves developer experience by eliminating the need to manually import and register models throughout your application.

## What is the Models Registry?

The models registry is a generated class that provides convenient access to all your models through a single import. Instead of importing each model individually and manually managing model instances, you can use a centralized registry that automatically discovers all your models.

### Why Use It?

- **Single Import**: Import one file instead of multiple model files
- **Automatic Discovery**: No need to manually list models - they're discovered automatically
- **Clean Initialization**: Use `Db.allModels()` instead of manually creating lists
- **Consistent Access**: Use `Db.users`, `Db.posts` instead of `Users.model`, `Post.model`
- **Type Safety**: Full IDE autocomplete support
- **Zero Configuration**: File name determines everything - no build.yaml config needed

## Quick Example

### Before (Without Registry)

```dart
import 'package:myapp/models/users.model.dart';
import 'package:myapp/models/post.model.dart';
import 'package:myapp/models/post_details.model.dart';

await sequelize.initialize(
  models: [
    Users.model,
    Post.model,
    PostDetails.model,
  ],
);

final user = await Users.model.findOne(...);
final post = await Post.model.create(...);
```

### After (With Registry)

```dart
import 'package:myapp/models/db.dart';

await sequelize.initialize(
  models: Db.allModels(),
);

final user = await Db.users.findOne(...);
final post = await Db.post.create(...);
```

## Getting Started

### Step 1: Create a Registry File

Create a `.registry.dart` file anywhere in your `lib/` directory. The file name determines the generated class name:

```dart
// lib/models/db.registry.dart
// This file triggers the models registry generator
// It will generate db.dart with a Db class
```

**Naming Conventions:**

- `db.registry.dart` → Generates `Db` class in `db.dart`
- `models.registry.dart` → Generates `Models` class in `models.dart`
- `database.registry.dart` → Generates `Database` class in `database.dart`
- `schema.registry.dart` → Generates `Schema` class in `schema.dart`

The registry file can be in any directory:

- `lib/models/db.registry.dart` → `lib/models/db.dart`
- `lib/db.registry.dart` → `lib/db.dart`
- `lib/schema/database.registry.dart` → `lib/schema/database.dart`

### Step 2: Run Build Runner

Generate the registry class:

```bash
dart run build_runner build --delete-conflicting-outputs
```

The generator will:

1. Scan all `.model.dart` files in your project
2. Extract model information from each file
3. Generate a registry class with static getters for each model
4. Create the output file in the same directory as the registry file

### Step 3: Import and Use

Import the generated registry file and use it:

```dart
import 'package:myapp/models/db.dart';

void main() async {
  final sequelize = Sequelize().createInstance(
    PostgressConnection(url: connectionString),
  );

  // Initialize with all models
  await sequelize.initialize(
    models: Db.allModels(),
  );

  // Access individual models
  final user = await Db.users.findOne(where: (u) => u.id.eq(1));
  final posts = await Db.post.findAll();

  await sequelize.close();
}
```

## How It Works

### Automatic Model Discovery

The registry generator automatically scans your entire `lib/` directory for files matching the pattern `**/*.model.dart`. It then:

1. Analyzes each model file to find classes annotated with `@Table`
2. Extracts the model class name and generated class name
3. Determines the import path for each model
4. Generates a registry class with static getters for each discovered model

### Class Name Derivation

The class name is automatically derived from the registry file name by capitalizing the first letter:

| Registry File            | Generated Class |
| ------------------------ | --------------- |
| `db.registry.dart`       | `Db`            |
| `models.registry.dart`   | `Models`        |
| `database.registry.dart` | `Database`      |
| `schema.registry.dart`   | `Schema`        |

### Generated Code Structure

For a registry file `lib/models/db.registry.dart`, the generator creates `lib/models/db.dart` with:

```dart
import 'package:myapp/models/post.model.dart';
import 'package:myapp/models/users.model.dart';
// ... other model imports

import 'package:sequelize_orm/sequelize_orm.dart';

/// Registry class for accessing all models
class Db {
  Db._();

  /// Returns the Post model instance
  static PostModel get post => PostModel();

  /// Returns the Users model instance
  static UsersModel get users => UsersModel();

  /// Returns a list of all model instances
  static List<Model> allModels() {
    return [
      Db.post,
      Db.users,
      // ... all other models
    ];
  }
}
```

### Output File Location

The generated file is always created in the same directory as the registry file:

- `lib/models/db.registry.dart` → `lib/models/db.dart`
- `lib/database.registry.dart` → `lib/database.dart`
- `lib/schema/models.registry.dart` → `lib/schema/models.dart`

## Usage Examples

### Basic Initialization

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:myapp/models/db.dart';

Future<void> main() async {
  final sequelize = Sequelize().createInstance(
    PostgressConnection(url: connectionString),
  );

  // Single line to initialize all models
  await sequelize.initialize(
    models: Db.allModels(),
  );

  // Your application code here

  await sequelize.close();
}
```

### Accessing Individual Models

```dart
import 'package:myapp/models/db.dart';

// Find records
final user = await Db.users.findOne(where: (u) => u.id.eq(1));
final posts = await Db.post.findAll(limit: 10);

// Create records
await Db.users.create(
  CreateUsers(
    email: 'user@example.com',
    firstName: 'John',
    lastName: 'Doe',
  ),
);

// Update records
await Db.post.update(
  views: 100,
  where: (p) => p.id.eq(1),
);

// Delete records
await Db.users.delete(where: (u) => u.id.eq(10));
```

### Multiple Registries

You can create multiple registries in different directories for better organization:

```dart
// lib/models/db.registry.dart → generates lib/models/db.dart
import 'package:myapp/models/db.dart';

// lib/schema/database.registry.dart → generates lib/schema/database.dart
import 'package:myapp/schema/database.dart';

// Use both registries
await sequelize.initialize(
  models: [
    ...Db.allModels(),
    ...Database.allModels(),
  ],
);
```

### Real-World Example

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:myapp/models/db.dart';

Future<void> seedDatabase() async {
  // Create a user with associated posts
  await Db.users.create(
    CreateUsers(
      email: 'john@example.com',
      firstName: 'John',
      lastName: 'Doe',
      posts: [
        CreatePost(
          title: 'My First Post',
          content: 'This is the content',
          views: 0,
        ),
        CreatePost(
          title: 'My Second Post',
          content: 'More content here',
          views: 0,
        ),
      ],
    ),
  );
}

Future<void> queryData() async {
  // Find user with posts included
  final user = await Db.users.findOne(
    include: (includeUsers) => [
      includeUsers.posts(),
    ],
    where: (u) => u.email.eq('john@example.com'),
  );

  // Update post views
  await Db.post.increment(
    views: 1,
    where: (p) => p.id.eq(1),
  );
}
```

## Developer Experience Improvements

### 1. Single Import vs Multiple Imports

**Before:**

```dart
import 'package:myapp/models/users.model.dart';
import 'package:myapp/models/post.model.dart';
import 'package:myapp/models/post_details.model.dart';
import 'package:myapp/models/comment.model.dart';
import 'package:myapp/models/category.model.dart';
// ... many more imports
```

**After:**

```dart
import 'package:myapp/models/db.dart';
// That's it!
```

### 2. Automatic Model Discovery

**Before:** Manually maintain a list of all models:

```dart
await sequelize.initialize(
  models: [
    Users.model,
    Post.model,
    PostDetails.model,
    Comment.model,
    Category.model,
    // ... forgot to add Tag.model? That's a runtime error!
  ],
);
```

**After:** Automatic discovery - never miss a model:

```dart
await sequelize.initialize(
  models: Db.allModels(), // All models are automatically included
);
```

### 3. Clean Initialization

**Before:** Verbose manual list creation:

```dart
final models = <Model>[
  Users.model,
  Post.model,
  PostDetails.model,
  // ... maintain this list manually
];

await sequelize.initialize(models: models);
```

**After:** Clean one-liner:

```dart
await sequelize.initialize(models: Db.allModels());
```

### 4. Consistent Access Pattern

**Before:** Inconsistent access patterns:

```dart
Users.model.findOne(...)      // Users class
Post.model.create(...)        // Post class
PostDetails.model.delete(...) // PostDetails class
```

**After:** Consistent, predictable access:

```dart
Db.users.findOne(...)      // All through Db
Db.post.create(...)        // Consistent pattern
Db.postDetails.delete(...) // Easy to remember
```

### 5. Type Safety & IDE Support

The registry provides full type safety and IDE autocomplete:

```dart
Db. // IDE shows: users, post, postDetails, ...
Db.users. // IDE shows: findOne, findAll, create, update, ...
```

### 6. Zero Configuration

**Before:** Required build.yaml configuration:

```yaml
builders:
  models_registry_builder:
    options:
      className: Models
      outputFileName: models
      entryFileName: models
```

**After:** No configuration needed - file name determines everything:

```dart
// Just create db.registry.dart → automatically generates Db class
```

### 7. Easier Refactoring

When you rename a model class or add/remove models:

**Before:** Update imports and model lists throughout the codebase

**After:** The registry regenerates automatically - no manual updates needed

## Comparison: Before vs After

### Complete Example Comparison

**Before (Without Registry):**

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:myapp/models/users.model.dart';
import 'package:myapp/models/post.model.dart';
import 'package:myapp/models/post_details.model.dart';

const connectionString = 'postgresql://user:pass@localhost/db';

Future<void> main() async {
  final sequelize = Sequelize().createInstance(
    PostgressConnection(url: connectionString),
  );

  // Manual model registration
  await sequelize.initialize(
    models: [
      Users.model,
      Post.model,
      PostDetails.model,
    ],
  );

  // Inconsistent access pattern
  final user = await Users.model.findOne(...);
  await Post.model.create(...);
  await PostDetails.model.delete(...);

  await sequelize.close();
}
```

**After (With Registry):**

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:myapp/models/db.dart';

const connectionString = 'postgresql://user:pass@localhost/db';

Future<void> main() async {
  final sequelize = Sequelize().createInstance(
    PostgressConnection(url: connectionString),
  );

  // Clean, automatic initialization
  await sequelize.initialize(
    models: Db.allModels(),
  );

  // Consistent access pattern
  final user = await Db.users.findOne(...);
  await Db.post.create(...);
  await Db.postDetails.delete(...);

  await sequelize.close();
}
```

### Key Benefits Summary

| Feature            | Before                 | After                   |
| ------------------ | ---------------------- | ----------------------- |
| Imports            | Multiple model imports | Single registry import  |
| Model Registration | Manual list            | Automatic discovery     |
| Initialization     | Verbose list           | One-line `allModels()`  |
| Access Pattern     | `Model.model`          | `Db.model` (consistent) |
| Configuration      | Required in build.yaml | Zero configuration      |
| Refactoring        | Manual updates needed  | Automatic regeneration  |

## Best Practices

### When to Use a Registry

Use a models registry when you:

- Have multiple models (3+ models)
- Want consistent model access patterns
- Need to initialize all models at once
- Want to reduce import clutter
- Prefer automatic model discovery

### Naming Conventions

- Use descriptive, short names: `db`, `models`, `database`, `schema`
- Choose names that make sense in your codebase context
- Keep registry files close to your models (same directory or `lib/` root)

### Organizing Registries in Large Projects

For large projects with many models, consider:

1. **Single Registry**: One registry for all models

   ```dart
   // lib/models/db.registry.dart
   import 'package:myapp/models/db.dart';
   ```

2. **Domain-Based Registries**: Separate registries by domain

   ```dart
   // lib/auth/models.registry.dart → AuthModels class
   // lib/ecommerce/models.registry.dart → EcommerceModels class
   import 'package:myapp/auth/models.dart';
   import 'package:myapp/ecommerce/models.dart';
   ```

3. **Feature-Based Registries**: One registry per feature module
   ```dart
   // lib/users/db.registry.dart → UsersDb class
   // lib/posts/db.registry.dart → PostsDb class
   ```

### Model Naming in Registry

The registry automatically converts model class names to camelCase for getter names:

| Model Class   | Registry Getter  |
| ------------- | ---------------- |
| `Users`       | `Db.users`       |
| `Post`        | `Db.post`        |
| `PostDetails` | `Db.postDetails` |
| `UserProfile` | `Db.userProfile` |

## Troubleshooting

### Registry Not Generating

If the registry file doesn't generate:

1. **Check file name**: Must end with `.registry.dart`
2. **Run build_runner**: `dart run build_runner build --delete-conflicting-outputs`
3. **Check for model files**: Registry generator needs at least one `.model.dart` file
4. **Verify builder is enabled**: Check `build.yaml` has the registry builder enabled

### Class Name Not Correct

The class name is derived from the registry file name:

- `db.registry.dart` → `Db` (capitalizes first letter)
- `database.registry.dart` → `Database`
- `models.registry.dart` → `Models`

Make sure your registry file follows the naming pattern.

### Models Not Appearing

If models don't appear in the registry:

1. **Check model files**: Must be named `*.model.dart`
2. **Check annotations**: Models must have `@Table` annotation
3. **Rebuild**: Run `dart run build_runner build --delete-conflicting-outputs`

## Summary

The Models Registry Generator is a powerful tool that significantly improves developer experience by:

- **Simplifying imports**: One import instead of many
- **Automating discovery**: No manual model registration
- **Providing consistency**: Unified access pattern (`Db.model`)
- **Requiring zero config**: File name determines everything
- **Enhancing type safety**: Full IDE autocomplete support

Start using it today by creating a simple `db.registry.dart` file and let the generator do the rest!
