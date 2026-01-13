---
sidebar_position: 9
---

# Complete Model Example

Here's a complete example with all features:

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

part 'users.model.g.dart';

@Table(
  tableName: 'users',
  underscored: true,
  timestamps: true,
  name: ModelNameOption(singular: 'user', plural: 'users'),
)
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
    allowNull: false,
    validate: ValidateOption(
      isEmail: IsEmail(),
      notEmpty: NotEmpty(),
    ),
  )
  dynamic email;

  @ModelAttributes(
    name: 'first_name',
    type: DataType.STRING,
    allowNull: false,
    validate: ValidateOption(
      len: Len(min: 1, max: 50),
    ),
  )
  dynamic firstName;

  @ModelAttributes(
    name: 'last_name',
    type: DataType.STRING,
    allowNull: false,
  )
  dynamic lastName;

  @ModelAttributes(
    name: 'age',
    type: DataType.INTEGER,
    validate: ValidateOption(
      min: Min(0),
      max: Max(150),
    ),
  )
  dynamic age;

  @ModelAttributes(
    name: 'is_active',
    type: DataType.BOOLEAN,
    defaultValue: true,
  )
  dynamic isActive;

  static $Users get instance => $Users();
}
```

## Generating Model Code

After defining your model, generate the implementation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This creates the `*.model.g.dart` file with the model implementation.
