# sequelize_dart_generator

Code generator for Sequelize Dart. This package automatically generates model implementations from annotated classes.

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
  )
  dynamic email;

  static $Users get instance => $Users();
}
```

### 2. Run Code Generation

Generate the model implementation:

```bash
# One-time generation
dart run build_runner build

# Watch mode (regenerates on file changes)
dart run build_runner watch
```

### 3. Use the Generated Model

The generator creates a `$Users` class that extends `Model`:

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'models/users.model.dart';

void main() async {
  var sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: 'postgresql://user:password@localhost:5432/dbname',
      ssl: false,
      logging: (String sql) => print(sql),
    ),
  );

  await sequelize.authenticate();
  sequelize.addModels([Users.instance]);

  // Use the generated model
  var users = await Users.instance.findAll();
}
```

## Generated Files

The generator creates `.g.dart` files next to your model files:

```
lib/
  models/
    users.model.dart      # Your model definition
    users.model.g.dart    # Generated implementation
```

## What Gets Generated

The generator creates:

1. **Model Implementation Class** (`$Users`):
   - Extends `Model`
   - Implements all query methods (`findAll`, `findOne`, `create`, etc.)
   - Handles attribute serialization/deserialization

2. **Model Name**:
   - Automatically extracts from class name or `tableName`

3. **Attribute Definitions**:
   - Converts annotations to Sequelize attribute definitions
   - Handles data type mapping
   - Processes foreign keys and relationships

## Configuration

The generator uses `build.yaml` configuration. No additional configuration is typically needed.

## Troubleshooting

### Generated files not updating

Delete generated files and rebuild:

```bash
dart run build_runner clean
dart run build_runner build
```

### Import errors

Ensure your model file has the correct `part` directive:

```dart
part 'users.model.g.dart';  // Must match filename
```

## See Also

- [sequelize_dart](../sequelize_dart/README.md) - Main package
- [sequelize_dart_annotations](../sequelize_dart_annotations/README.md) - Annotations package


