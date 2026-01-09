# Code Generator Guide

This guide explains how the Sequelize Dart code generator works and how to extend it.

## Overview

The generator is a `build_runner` package that reads model classes annotated with `@Table` and generates implementation code.

## Generated Output

For a model like:

```dart
@Table(tableName: 'users')
class Users {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;

  @ModelAttributes(name: 'email', type: DataType.STRING)
  dynamic email;

  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static $Users get instance => $Users();
}
```

The generator produces `users.model.g.dart` with:

1. **`$Users`** - Main model class
2. **`$UsersValues`** - Data class for results
3. **`$UsersCreate`** - DTO for creating records
4. **`$UsersColumns`** - Type-safe column references
5. **`$UsersQuery`** - Query builder with associations
6. **`$UsersIncludeHelper`** - Type-safe include builder

## Generator Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    SequelizeModelGenerator                              │
│                    (sequelize_model_generator.dart)                     │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
                                │ extends GeneratorForAnnotation<Table>
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    generateForAnnotatedElement()                        │
│                                                                         │
│  1. Extract table annotation                                            │
│  2. Get fields with @ModelAttributes                                    │
│  3. Get associations (@HasOne, @HasMany)                                │
│  4. Call individual generators                                          │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    Individual Method Generators                         │
│                    (generators/methods/*.dart)                          │
│                                                                         │
│  _generateClassDefinition()     _generateFindAllMethod()               │
│  _generateDefineMethod()        _generateFindOneMethod()               │
│  _generateGetAttributesMethod() _generateCountMethod()                  │
│  _generateGetOptionsJsonMethod() _generateMaxMethod()                   │
│  _generateClassValues()         _generateMinMethod()                    │
│  _generateClassCreate()         _generateSumMethod()                    │
│  _generateColumns()             _generateIncrementMethod()              │
│  _generateQueryBuilder()        _generateDecrementMethod()              │
│  _generateIncludeHelper()       _generateAssociateModelMethod()         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Key Files

| File                              | Purpose                          |
| --------------------------------- | -------------------------------- |
| `builder.dart`                    | Build runner configuration       |
| `sequelize_model_generator.dart`  | Main generator class             |
| `_extract_table_annotation.dart`  | Parse @Table annotation          |
| `_get_fields.dart`                | Extract @ModelAttributes fields  |
| `_get_associations.dart`          | Extract @HasOne/@HasMany         |
| `_generate_class_definition.dart` | Generate $ModelName class        |
| `_generate_class_values.dart`     | Generate $ModelNameValues        |
| `_generate_columns.dart`          | Generate $ModelNameColumns       |
| `_generate_query_builder.dart`    | Generate $ModelNameQuery         |
| `_generate_include_helper.dart`   | Generate $ModelNameIncludeHelper |
| `_generate_find_all_method.dart`  | Generate findAll()               |
| `_generate_find_one_method.dart`  | Generate findOne()               |
| `_generate_count_method.dart`     | Generate count()                 |
| `_generate_increment_method.dart` | Generate increment/decrement     |

## Data Structures

### \_FieldInfo

Represents a model field:

```dart
class _FieldInfo {
  final String name;           // Column name in DB
  final String dartName;       // Property name in Dart
  final String dartType;       // Dart type (int, String, etc.)
  final DataType dataType;     // Sequelize data type
  final bool primaryKey;
  final bool autoIncrement;
  final bool allowNull;
  final dynamic defaultValue;
  final String? validate;      // Validation options JSON
}
```

### \_AssociationInfo

Represents a model association:

```dart
class _AssociationInfo {
  final String type;           // 'HasOne' or 'HasMany'
  final String targetModel;    // Target model class name
  final String foreignKey;     // Foreign key column
  final String as;             // Association alias
  final String? sourceKey;     // Source key (optional)
}
```

## Adding a New Generated Method

### Step 1: Create Generator File

Create `packages/sequelize_dart_generator/lib/src/generators/methods/_generate_my_method.dart`:

```dart
part of '../../sequelize_model_generator.dart';

void _generateMyMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
  String whereCallbackName,
  List<_FieldInfo> fields,
) {
  final columnsClassName = '\$${className}Columns';

  // Generate method signature
  buffer.writeln('  @override');
  buffer.writeln('  Future<ReturnType> myMethod({');
  buffer.writeln('    QueryOperator Function($columnsClassName $whereCallbackName)? where,');
  buffer.writeln('  }) {');

  // Generate method body
  buffer.writeln('    final columns = $columnsClassName();');
  buffer.writeln('    final query = Query.fromCallbacks(');
  buffer.writeln('      where: where,');
  buffer.writeln('      columns: columns,');
  buffer.writeln('    );');
  buffer.writeln('    return QueryEngine().myMethod(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
```

### Step 2: Add Part Directive

In `sequelize_model_generator.dart`, add:

```dart
part 'generators/methods/_generate_my_method.dart';
```

### Step 3: Call Generator

In `generateForAnnotatedElement()`:

```dart
_generateMyMethod(
  buffer,
  className,
  valuesClassName,
  baseCallbackName,
  fields,
);
```

## Common Patterns

### Generating Type-Safe Where Clause

```dart
buffer.writeln('    QueryOperator Function(\$${className}Columns $callbackName)? where,');
// ...
buffer.writeln('    final query = Query.fromCallbacks(');
buffer.writeln('      where: where,');
buffer.writeln('      columns: \$${className}Columns(),');
buffer.writeln('    );');
```

### Generating Include Parameter

```dart
buffer.writeln('    List<IncludeBuilder> Function(\$${className}IncludeHelper $includeCallbackName)? include,');
// ...
buffer.writeln('    final includeHelper = const \$${className}IncludeHelper();');
buffer.writeln('    final query = Query.fromCallbacks(');
buffer.writeln('      include: include,');
buffer.writeln('      includeHelper: includeHelper,');
buffer.writeln('    );');
```

### Generating Return Type Mapping

```dart
// For list results
buffer.writeln('    ).then((data) =>');
buffer.writeln('      data.map((value) => $valuesClassName.fromJson(value)).toList()');
buffer.writeln('    );');

// For single result
buffer.writeln('    ).then((data) => data != null ? $valuesClassName.fromJson(data) : null);');
```

### Generating Field-Based Parameters

```dart
// Filter fields by criteria
final numericFields = fields.where((f) =>
  f.dartType == 'int' || f.dartType == 'double'
).toList();

// Generate parameter for each field
for (final field in numericFields) {
  final camelCaseName = _toCamelCase(field.name);
  buffer.writeln('    int? $camelCaseName,');
}
```

## Naming Configuration

The generator supports customizable callback parameter names:

```dart
final namingConfig = GeneratorNamingConfig.fromOptions(options);

// Get where callback name (e.g., 'user' for Users model)
final baseCallbackName = namingConfig.getWhereCallbackName(
  singular: singularName,
  plural: pluralName,
);

// Get include callback name (e.g., 'includeUser')
final includeParamName = namingConfig.getIncludeCallbackName(
  singular: singularName,
  plural: pluralName,
);
```

## Helper Functions

### \_toCamelCase

Converts snake_case to camelCase:

```dart
String _toCamelCase(String input) {
  final words = input.split('_');
  return words.first +
    words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
}
```

### \_getDartTypeForQuery

Maps DataType to Dart type:

```dart
String _getDartTypeForQuery(DataType type) {
  switch (type) {
    case DataType.INTEGER:
    case DataType.BIGINT:
      return 'int';
    case DataType.FLOAT:
    case DataType.DOUBLE:
      return 'double';
    case DataType.STRING:
    case DataType.TEXT:
      return 'String';
    case DataType.BOOLEAN:
      return 'bool';
    // ...
  }
}
```

## Testing Generator Changes

1. **Make changes** to generator files
2. **Run build_runner** in example:
   ```bash
   cd example
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **Check generated output** in `example/lib/models/*.g.dart`
4. **Run tests** to verify functionality

## Generated Code Structure

### Model Class ($Users)

```dart
class $Users extends Model {
  static final $Users _instance = $Users._internal();

  @override
  String get name => 'Users';

  $Users._internal();
  factory $Users() => _instance;

  $UsersColumns get columns => $UsersColumns();

  @override
  $Users define(String modelName, Object sequelize) { ... }

  @override
  List<ModelAttributes> getAttributes() { ... }

  @override
  Future<List<$UsersValues>> findAll({ ... }) { ... }

  @override
  Future<$UsersValues?> findOne({ ... }) { ... }

  @override
  Future<int> count({ ... }) { ... }

  @override
  Future<void> associateModel() async { ... }
}
```

### Values Class ($UsersValues)

```dart
class $UsersValues {
  final int? id;
  final String? email;
  final List<$PostValues>? posts;  // Association

  $UsersValues({ this.id, this.email, this.posts });

  factory $UsersValues.fromJson(Map<String, dynamic> json) {
    return $UsersValues(
      id: json['id'],
      email: json['email'],
      posts: (json['posts'] as List?)
          ?.map((e) => $PostValues.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() { ... }
}
```

### Columns Class ($UsersColumns)

```dart
class $UsersColumns {
  final id = Column<int>('id', DataType.INTEGER);
  final email = Column<String>('email', DataType.STRING);
}
```

### Include Helper ($UsersIncludeHelper)

```dart
class $UsersIncludeHelper {
  const $UsersIncludeHelper();

  IncludeBuilder<Post> posts({
    bool? separate,
    bool? required,
    QueryOperator Function($PostColumns posts)? where,
    // ... more options
  }) {
    return IncludeBuilder<Post>(
      association: 'posts',
      model: Post.instance,
      separate: separate,
      required: required,
      where: where != null ? where($PostColumns()) : null,
    );
  }
}
```

## Debugging Tips

1. **Print buffer contents**: Add `print(buffer.toString())` before returning
2. **Check annotation parsing**: Log extracted fields and associations
3. **Verify generated syntax**: Run `dart analyze` on generated files
4. **Test incrementally**: Generate one method at a time
