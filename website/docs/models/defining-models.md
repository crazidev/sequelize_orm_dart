---
sidebar_position: 1
---

# Defining Models

Models in Sequelize Dart are regular Dart classes annotated with `@Table` and `@ModelAttributes`. Here's the basic structure:

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

part 'users.model.g.dart';

@Table()
class Users {
  @ModelAttributes(type: DataType.STRING)
  String firstName;

  @ModelAttributes(type: DataType.STRING)
  String lastName;

  static $Users get instance => $Users();
}
```

## Table Annotation Options

The `@Table` annotation accepts several options:

- `tableName`: The name of the database table (required)
- `underscored`: Use snake_case for column names (default: `false`)
- `timestamps`: Automatically add `createdAt` and `updatedAt` (default: `true`)
- `createdAt`: Custom name for createdAt column
- `updatedAt`: Custom name for updatedAt column
- `name`: Model name options (singular/plural)
