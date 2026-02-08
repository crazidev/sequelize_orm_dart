# sequelize_dart_generator

Code generator for Sequelize Dart. Automatically generates model implementations from annotated classes, providing type-safe query builders and CRUD operations.

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  sequelize_dart_generator:
    path: ../packages/sequelize_dart_generator # For local development
  build_runner: ^2.10.4
```

Then run:

```bash
dart pub get
```

## Setup

### 1. Define Your Model

```dart
// lib/models/users.model.dart
import 'package:sequelize_dart/sequelize_dart.dart';

part 'users.model.g.dart';

@Table(tableName: 'users', timestamps: false)
class Users {
  @PrimaryKey()
  @AutoIncrement()
  @NotNull()
  DataType id = DataType.INTEGER;

  @NotNull()
  DataType email = DataType.STRING;

  @ColumnName('first_name')
  DataType firstName = DataType.STRING;

  static UsersModel get model => UsersModel();
}
```

### 2. Run Code Generation

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (regenerates on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

This creates `users.model.g.dart` with the generated implementation.

## Generated Classes

For a model class named `Users`, the generator creates:

### 1. `UsersModel` (extends `Model`)

The main model class with static singleton access:

```dart
class UsersModel extends Model {
  // Access via: Users.model
  static UsersModel get model => UsersModel();
}
```

**Methods:**

- `Future<List<UsersValues>> findAll({...})` - Find all records
- `Future<UsersValues?> findOne({...})` - Find single record
- `Future<UsersValues?> findByPrimaryKey(dynamic id)` - Find by primary key
- `Future<UsersValues> create(CreateUsers data)` - Create new record
- `Future<int> update({...})` - Update records
- `Future<int> count({...})` - Count records
- `Future<num?> max(Column Function(UsersColumns) columnFn, {...})` - Get maximum value
- `Future<num?> min(Column Function(UsersColumns) columnFn, {...})` - Get minimum value
- `Future<num?> sum(Column Function(UsersColumns) columnFn, {...})` - Sum column values
- `Future<void> associateModel()` - Setup associations

### 2. `UsersValues`

Model instance class with data fields and methods:

```dart
class UsersValues with ReloadableMixin<UsersValues> {
  int? id;
  String? email;
  String? firstName;
  // ... other fields

  // Methods
  Future<UsersValues?> reload() - Reload from database
  Future<int> save({List<String>? fields}) - Save changes
  Future<int> update(Map<String, dynamic> data) - Update instance
  Map<String, dynamic> toJson() - Convert to JSON
  factory UsersValues.fromJson(Map<String, dynamic>) - Create from JSON
}
```

### 3. `CreateUsers`

Type-safe create helper class with named parameters:

```dart
class CreateUsers {
  final String? email;
  final String? firstName;
  // ... other fields

  CreateUsers({
    this.email,
    this.firstName,
    // ...
  });
}

// Usage
await Users.model.create(CreateUsers(
  email: 'user@example.com',
  firstName: 'John',
));
```

### 4. `UpdateUsers`

Type-safe update helper class (optional, based on configuration):

```dart
class UpdateUsers {
  final String? email;
  final String? firstName;
  // ...
}
```

### 5. `UsersColumns`

Type-safe column accessors for query building:

```dart
class UsersColumns {
  Column<int> get id => Column('id');
  Column<String> get email => Column('email');
  Column<String> get firstName => Column('first_name');
  // ... other columns
}

// Usage in queries
Users.model.findAll(
  where: (users) => users.email.equals('user@example.com'),
);
```

### 6. `UsersQuery` (extends `UsersColumns`)

Advanced query builder with additional helper methods:

```dart
class UsersQuery extends UsersColumns {
  // Additional query building methods
}
```

### 7. `UsersIncludeHelper`

Helper for building association includes:

```dart
class UsersIncludeHelper {
  // Methods for each association
  IncludeBuilder post() { /* ... */ }
  IncludeBuilder posts() { /* ... */ }
}

// Usage
Users.model.findAll(
  include: (include) => [include.post()],
);
```

## Generated Methods Reference

### Query Methods

All query methods support:

- `where: QueryOperator Function(UsersColumns)` - Filter conditions
- `include: List<IncludeBuilder> Function(UsersIncludeHelper)` - Eager load associations
- `order: dynamic` - Sorting (array of `[column, 'ASC'|'DESC']`)
- `limit: int?` - Limit results
- `offset: int?` - Skip results
- `attributes: QueryAttributes?` - Select specific columns

**findAll**

```dart
Future<List<UsersValues>> findAll({
  QueryOperator Function(UsersColumns)? where,
  List<IncludeBuilder> Function(UsersIncludeHelper)? include,
  dynamic order,
  int? limit,
  int? offset,
  // ...
})
```

**findOne**

```dart
Future<UsersValues?> findOne({
  QueryOperator Function(UsersColumns)? where,
  List<IncludeBuilder> Function(UsersIncludeHelper)? include,
  // ...
})
```

**create**

```dart
Future<UsersValues> create(CreateUsers createData)
// or
Future<UsersValues> create(Map<String, dynamic> data)
```

**update**

```dart
Future<int> update({
  String? email,
  String? firstName,
  // ... other fields as named parameters
  QueryOperator Function(UsersColumns)? where,
})
```

**count**

```dart
Future<int> count({
  QueryOperator Function(UsersColumns)? where,
})
```

**max / min / sum**

```dart
Future<num?> max(
  Column Function(UsersColumns) columnFn, {
  QueryOperator Function(UsersColumns)? where,
})

Future<num?> min(
  Column Function(UsersColumns) columnFn, {
  QueryOperator Function(UsersColumns)? where,
})

Future<num?> sum(
  Column Function(UsersColumns) columnFn, {
  QueryOperator Function(UsersColumns)? where,
})
```

### Instance Methods (UsersValues)

**reload**

```dart
Future<UsersValues?> reload()
```

**save**

```dart
Future<int> save({List<String>? fields})
```

**update**

```dart
Future<int> update(Map<String, dynamic> data)
```

## Configuration

While the generator works with `build.yaml`, you can create a `sequelize.yaml` file in your project root for more advanced features like database connections and seeding.

### sequelize.yaml

```yaml
models_path: lib/models
seeders_path: lib/seeders # Optional: path to seeder classes
registry_path: lib/db/db.dart # Optional: override generated registry path

connection:
  default:
    dialect: postgres
    host: env.DB_HOST
    port: env.DB_PORT
    database: env.DB_NAME
    user: env.DB_USER
    pass: env.DB_PASS
    ssl: true
  dev:
    url: sqlite://dev.db
```

### Environment Variables (.env)

The generator automatically loads a `.env` file from the project root. You can reference these variables in `sequelize.yaml` using the `env.` prefix.

## CLI Tools

The generator provides several CLI commands via `dart run sequelize_dart_generator:generate`.

### Database Seeding

You can run your database seeders directly from the CLI:

```bash
# Run seeders using the 'default' profile
dart run sequelize_dart_generator:generate --seed

# Run seeders using a specific profile from sequelize.yaml
dart run sequelize_dart_generator:generate --seed --database dev

# Verbose mode (shows SQL queries and status)
dart run sequelize_dart_generator:generate --seed -v

# Force sync before seeding (drops and recreates tables)
dart run sequelize_dart_generator:generate --seed --force
```

### Manual Registry Generation

Generate your `@db.dart` registry file manually:

```bash
dart run sequelize_dart_generator:generate --registry
```

## Troubleshooting

### Generated files not updating

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Import errors

Ensure your model file has the correct `part` directive:

```dart
part 'users.model.g.dart';  // Must match filename exactly
```

### Build errors

- Ensure all annotations are imported from `package:sequelize_dart/sequelize_dart.dart`
- Check that field types use `DataType` enum
- Verify `@Table` annotation has required `tableName` parameter

## See Also

- [sequelize_dart](../sequelize_dart/README.md) - Main package
- [Documentation](../../docs/) - Full documentation
