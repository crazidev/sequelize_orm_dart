# sequelize_dart

A Dart ORM for Sequelize.js integration with code generation support. Provides database connectivity, query building, and model management for PostgreSQL, MySQL, and MariaDB.

## Installation

```yaml
dependencies:
  sequelize_dart:
    path: ../packages/sequelize_dart # For local development
    # or
    # sequelize_dart: ^1.0.0          # When published
```

## Quick Start

```dart
import 'package:sequelize_dart/sequelize_dart.dart';

void main() async {
  // Create connection
  final sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: 'postgresql://user:pass@localhost:5432/dbname',
    ),
  );

  // Initialize models
  await sequelize.initialize(
    models: [Users.model, Post.model],
  );

  // Query data
  final users = await Users.model.findAll();

  await sequelize.close();
}
```

## Documentation

For complete documentation, examples, and guides, visit:

**[Full Documentation Site](https://your-docs-site.vercel.app)** _(hosted on Vercel)_

The documentation includes:

- Getting started guide
- Model definitions and annotations
- Querying and CRUD operations
- Associations and relationships
- Database connections
- Advanced topics

## Features

- 🚀 Dual Platform Support (Dart VM & dart2js)
- 📦 Code generation via `sequelize_dart_generator`
- 🔌 Multiple Databases (PostgreSQL, MySQL, MariaDB)
- 🎯 Type-Safe Queries
- 🔄 Connection Pooling
- 📝 Declarative Annotations

## See Also

- [sequelize_dart_generator](../sequelize_dart_generator/README.md) - Code generator
- [Documentation](../../docs/) - Full documentation site
