# Models

Models in Sequelize Dart are defined using annotations and code generation. This approach provides type safety and autocomplete support.

## Model Definition

### Basic Model Structure

Create a model file with the `@Table` annotation and `@ModelAttributes` for each field:

```dart
// lib/models/users.model.dart
import 'package:sequelize_dart/sequelize_dart.dart';

part 'users.model.g.dart';

@Table(tableName: 'users')
class Users {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  )
  dynamic id;

  @ModelAttributes(
    name: 'email',
    type: DataType.STRING,
    unique: true,
  )
  dynamic email;

  @ModelAttributes(
    name: 'firstName',
    type: DataType.STRING,
  )
  dynamic firstName;

  @ModelAttributes(
    name: 'lastName',
    type: DataType.STRING,
  )
  dynamic lastName;

  static $Users get instance => $Users();
}
```

### Model Attributes

The `@ModelAttributes` annotation accepts the following options:

- `name` (required) - Column name in the database
- `type` (required) - Data type (see [Data Types](#data-types))
- `primaryKey` - Set to `true` for primary key
- `autoIncrement` - Set to `true` for auto-incrementing fields
- `unique` - Set to `true` for unique constraints
- `notNull` - Set to `true` for NOT NULL constraints
- `defaultValue` - Default value for the field

### Table Options

The `@Table` annotation accepts:

- `tableName` (required) - Name of the database table
- `underscored` - Use snake_case for column names (default: `true`)
- `timestamps` - Automatically add `createdAt` and `updatedAt` (default: `true`)

Example with custom options:

```dart
@Table(
  tableName: 'users',
  underscored: true,
  timestamps: true,
)
class Users {
  // ...
}
```

## Code Generation

### Running the Generator

Generate model implementations using `build_runner`:

```bash
# One-time generation
dart run build_runner build

# Watch mode (auto-regenerates on changes)
dart run build_runner watch

# Clean build (deletes conflicting outputs)
dart run build_runner build --delete-conflicting-outputs
```

### Generated Classes

The generator creates three classes in `users.model.g.dart`:

#### 1. `$Users` - Model Class

The main model class that extends `Model`:

```dart
class $Users extends Model {
  static final $Users _instance = $Users._internal();
  
  factory $Users() {
    return _instance;
  }
  
  // Query methods
  Future<List<$UsersValues>> findAll([Query? options]);
  Future<$UsersValues?> findOne([Query? options]);
  Future<$UsersValues> create(Map<String, dynamic> data);
}
```

**Usage:**

```dart
// Access the singleton instance
var users = Users.instance; // Returns $Users

// Query methods
var allUsers = await Users.instance.findAll();
var user = await Users.instance.findOne(Query(where: equal('id', 1)));
var newUser = await Users.instance.create({'email': 'user@example.com'});
```

#### 2. `$UsersValues` - Value Class

Type-safe class representing a database record:

```dart
class $UsersValues {
  final int id;
  final String email;
  final String firstName;
  final String lastName;

  $UsersValues({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
```

**Usage:**

```dart
var users = await Users.instance.findAll();
for (var user in users) {
  print(user.email); // Type-safe access
  print(user.toJson()); // Convert to JSON
}
```

#### 3. `$UsersCreate` - Create Class

Type-safe class for creating new records (optional, generated for create operations):

```dart
class $UsersCreate {
  final String email;
  final String firstName;
  final String lastName;

  $UsersCreate({
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
```

## Data Types

Supported data types from `DataType` enum:

- `INTEGER` - Integer numbers
- `STRING` - Text strings
- `TEXT` - Long text
- `BOOLEAN` - Boolean values
- `DATE` - Date and time
- `DECIMAL` - Decimal numbers
- `FLOAT` - Floating point numbers
- `DOUBLE` - Double precision floats
- `BIGINT` - Large integers
- `UUID` - UUID strings
- `JSON` - JSON data
- `JSONB` - JSONB (PostgreSQL only)
- `BLOB` - Binary data
- `ENUM` - Enumeration values

Example:

```dart
@ModelAttributes(
  name: 'price',
  type: DataType.DECIMAL,
)
dynamic price;

@ModelAttributes(
  name: 'metadata',
  type: DataType.JSON,
)
dynamic metadata;
```

## Model Registration

After creating a Sequelize instance, register your models:

```dart
var sequelize = Sequelize().createInstance(
  PostgressConnection(url: '...'),
);

await sequelize.authenticate();

// Register models
sequelize.addModels([
  Users.instance,
  Posts.instance,
  // ... other models
]);
```

## Complete Example

```dart
// lib/models/posts.model.dart
import 'package:sequelize_dart/sequelize_dart.dart';

part 'posts.model.g.dart';

@Table(tableName: 'posts')
class Posts {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  )
  dynamic id;

  @ModelAttributes(
    name: 'title',
    type: DataType.STRING,
    notNull: true,
  )
  dynamic title;

  @ModelAttributes(
    name: 'content',
    type: DataType.TEXT,
  )
  dynamic content;

  @ModelAttributes(
    name: 'published',
    type: DataType.BOOLEAN,
    defaultValue: false,
  )
  dynamic published;

  @ModelAttributes(
    name: 'createdAt',
    type: DataType.DATE,
  )
  dynamic createdAt;

  static $Posts get instance => $Posts();
}
```

After running `dart run build_runner build`, you can use:

```dart
// Find all posts
var posts = await Posts.instance.findAll();

// Find published posts
var published = await Posts.instance.findAll(
  Query(where: equal('published', true)),
);

// Create a post
var newPost = await Posts.instance.create({
  'title': 'My First Post',
  'content': 'This is the content...',
  'published': true,
});
```

## Best Practices

1. **Always include the `part` directive** in your model files
2. **Use `static get instance`** to access the generated model
3. **Run code generation** after modifying model definitions
4. **Use type-safe `$ModelValues` classes** instead of raw maps when possible
5. **Register all models** before querying the database

## Next Steps

- Learn about [Connections](./connections.md) to configure database connections
- Explore [Querying](./querying.md) to query your models
- Check out [Typed Queries](./typed-queries.md) for type-safe query building
