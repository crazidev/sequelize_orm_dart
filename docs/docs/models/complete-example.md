---
sidebar_position: 9
---

# Complete Example

Here is a comprehensive example of a model definition using various annotations and options.

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart'; // Optional if exported by main package

part 'product.model.g.dart';

@Table(
  tableName: 'products',
  underscored: true,
  timestamps: true,
)
class Product {
  // Primary Key with Auto Increment
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  // String column with explicit name and not null constraint
  @ColumnName('product_name')
  @NotNull()
  @Validate.Len(2, 100)
  DataType name = DataType.STRING;

  // Text column allowing nulls
  @AllowNull()
  DataType description = DataType.TEXT;

  // Decimal with precision, default value, and numeric validation
  @Default(0.0)
  @Validate.Min(0)
  DataType price = DataType.DECIMAL(10, 2);

  // Enum-like string with specific allowed values
  @Default('draft')
  @Validate.IsIn(['draft', 'published', 'archived'])
  DataType status = DataType.STRING;

  // Boolean with default value
  @Default(true)
  DataType inStock = DataType.BOOLEAN;

  // UUID for tracking, auto-generated
  @Default.uniqid()
  DataType sku = DataType.UUID;

  // Virtual helper getter (not a DB column)
  bool get isPublished => status == 'published';

  // Sequelize instance getter
  static ProductModel get model => ProductModel();

}
```

### Generating the Code

Remember to run the build runner to generate the `part` file:

```bash
dart run build_runner build --delete-conflicting-outputs
```
