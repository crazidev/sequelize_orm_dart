# sequelize_dart_generator

Code generator for Sequelize Dart. This package automatically generates model implementations from annotated classes, providing type-safe query builders and CRUD operations.

## Installation

```yaml
dev_dependencies:
  sequelize_dart_generator:
    path: ../sequelize_dart_generator
  build_runner: ^2.10.4
```

## Usage

### 1. Define Your Model

Create a model file with annotations:

```dart
// lib/models/user.model.dart
import 'package:sequelize_dart/sequelize_dart.dart';

part 'user.model.g.dart';

@Table(tableName: 'users', underscored: true)
class User {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  @NotNull()
  DataType username = DataType.STRING;

  @ColumnName('email_address')
  DataType email = DataType.STRING;

  static $User get instance => $User();
}
```

### 2. Run Code Generation

Generate the model implementation:

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (regenerates on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

This creates `user.model.g.dart` with the generated `$User` class.

### 3. Use the Generated Model

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'models/user.model.dart';

void main() async {
  final sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: 'postgresql://user:password@localhost:5432/dbname',
    ),
  );

  await sequelize.initialize(
    models: [User.instance],
  );

  // Use the generated model
  final users = await User.instance.findAll();
  final user = await User.instance.findOne(
    where: (user) => user.email.equals('user@example.com'),
  );

  await sequelize.close();
}
```

## What Gets Generated

The generator creates a `$ClassName` class (e.g., `$User`) that extends `Model` and includes:

### 1. Query Methods

- `findAll()` - Find all records with optional conditions
- `findOne()` - Find a single record
- `findByPk()` - Find by primary key
- `count()` - Count records
- `create()` - Create new records
- `update()` - Update records
- `save()` - Save model instance
- `reload()` - Reload instance from database
- `delete()` - Delete instance

### 2. Aggregation Methods

- `sum()` - Sum values of a numeric column
- `max()` - Maximum value of a column
- `min()` - Minimum value of a column
- `increment()` - Increment numeric fields (if model has numeric fields)
- `decrement()` - Decrement numeric fields (if model has numeric fields)

### 3. Type-Safe Query Builders

Type-safe column accessors for building queries:

```dart
// Type-safe where clauses
User.instance.findAll(
  where: (user) => user.email.equals('user@example.com'),
);

// With logical operators
User.instance.findAll(
  where: (user) => and([
    user.email.isNotNull(),
    user.id.gt(0),
  ]),
);
```

### 4. Create Helper Classes

For type-safe record creation:

```dart
final user = await User.instance.create(
  $UserCreate(
    username: 'johndoe',
    email: 'john@example.com',
  ),
);
```

### 5. Column Definitions

Type-safe column accessors for each field:

```dart
// In where clauses
where: (user) => user.id.eq(1)
where: (user) => user.email.like('%@example.com')
where: (user) => user.age.between(18, 65)
```

### 6. Include Helpers

For eager loading associations:

```dart
User.instance.findAll(
  include: (include) => [include.post()],
);
```

## Generated File Structure

The generator creates `.g.dart` files next to your model files:

```
lib/
  models/
    user.model.dart      # Your model definition
    user.model.g.dart    # Generated implementation
```

The generated file contains:

1. **Model Class** (`$User`) - Extends `Model`, implements all query methods
2. **Create Helper** (`$UserCreate`) - Type-safe create method with named parameters
3. **Query Columns** - Type-safe column accessors for building queries
4. **Attribute Definitions** - Converts annotations to Sequelize attribute definitions

## Code Generation Details

### Model Definition

The generator extracts:

- Table name and options from `@Table` annotation
- Column definitions from field annotations
- Data types, constraints, and validators
- Foreign keys and relationships

### Attribute Mapping

- Converts `DataType` enum to Sequelize data types
- Processes `@PrimaryKey`, `@AutoIncrement`, `@NotNull` annotations
- Handles `@ColumnName` for custom column names
- Maps validators to Sequelize validation rules

### Query Generation

- Generates type-safe column accessors with all operators
- Creates `where` callback with full type safety
- Generates `include` helpers for associations
- Creates `order`, `limit`, `offset` builders

### Instance Methods

Generates instance methods for:

- `save()` - Persist changes to database
- `reload()` - Refresh from database
- `delete()` - Remove from database
- Attribute getters/setters with type safety

## Configuration

The generator uses `build.yaml` configuration. No additional configuration is typically needed.

## Generated Code Example

Here's what gets generated for a simple model:

```dart
// Generated: user.model.g.dart
class $User extends Model {
  @override
  String get tableName => 'users';

  // Column accessors for type-safe queries
  Column<int> get id => Column('id');
  Column<String> get username => Column('username');
  Column<String> get email => Column('email_address');

  // Query methods
  Future<List<User>> findAll({...});
  Future<User?> findOne({...});
  Future<User> create($UserCreate data);
  // ... and more
}
```

## Troubleshooting

### Generated files not updating

Delete generated files and rebuild:

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Import errors

Ensure your model file has the correct `part` directive:

```dart
part 'user.model.g.dart';  // Must match filename exactly
```

### Build errors

- Ensure all annotations are imported correctly
- Check that field types use `DataType` enum
- Verify `@Table` annotation has required `tableName` parameter

### Type errors

- Generated code depends on model annotations being correct
- Ensure `build_runner` is up to date
- Check that `sequelize_dart` and `sequelize_dart_annotations` are compatible versions

## See Also

- [sequelize_dart](../sequelize_dart/README.md) - Main package
- [sequelize_dart_annotations](../sequelize_dart_annotations/README.md) - Annotations package
