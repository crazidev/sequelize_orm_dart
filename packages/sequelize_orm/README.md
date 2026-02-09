# sequelize_orm

A Dart ORM for Sequelize.js integration with code generation support. Provides database connectivity, query building, and model management for PostgreSQL, MySQL, and MariaDB.

## Installation

```yaml
dependencies:
  sequelize_orm:
    path: ../packages/sequelize_orm # For local development
    # or
    # sequelize_orm: ^1.0.0          # When published
```

## Quick Start

```dart
import 'package:sequelize_orm/sequelize_orm.dart';

void main() async {
  // Create connection using factory methods
  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(
      url: 'postgresql://user:pass@localhost:5432/dbname',
    ),
    // Optional: Custom logging for SQL queries and status messages
    logging: (msg) => print('DB: $msg'),
  );

  // Initialize models (using generated registry)
  await sequelize.initialize(
    models: Db.allModels(),
  );

  // Query data
  final users = await Users.model.findAll();

  await sequelize.close();
}
```

## Logging

Sequelize Dart provides a powerful logging mechanism. You can pass a `logging` callback to `createInstance` to capture both SQL queries and internal state changes (like model definition progress).

```dart
final sequelize = Sequelize().createInstance(
  connection: ...,
  logging: (msg) {
    // msg can be a SQL query or a status message like "✅ Defining model: User"
    print(msg);
  },
);
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
- 📦 Code generation via `sequelize_orm_generator`
- 🔌 Multiple Databases (PostgreSQL, MySQL, MariaDB)
- 🎯 Type-Safe Queries
- 🔄 Connection Pooling
- 📝 Declarative Annotations

## See Also

- [sequelize_orm_generator](../sequelize_orm_generator/README.md) - Code generator
- [Documentation](../../docs/) - Full documentation site
