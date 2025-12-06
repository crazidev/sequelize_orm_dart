---
sidebar_position: 0
---

# Welcome to Sequelize Dart

Sequelize Dart is a powerful Dart ORM (Object-Relational Mapping) library that provides seamless integration with Sequelize.js. It offers code generation for type-safe models and works on both Dart server and dart2js platforms.

## Features

- 🚀 **Dual Platform Support**: Works on Dart server (via Node.js bridge) and dart2js (via JS interop)
- 📦 **Code Generation**: Automatic model implementation generation with type safety
- 🔌 **Multiple Databases**: PostgreSQL, MySQL, and MariaDB support
- 🎯 **Type-Safe Queries**: Strongly-typed query builders with autocomplete
- 🔄 **Connection Pooling**: Built-in connection pool management
- 📝 **Simple Annotations**: Declarative model definitions

## Quick Start

Get started in minutes:

```dart
// 1. Create a model
@Table(tableName: 'users')
class Users {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;
  
  @ModelAttributes(name: 'email', type: DataType.STRING)
  dynamic email;
  
  static $Users get instance => $Users();
}

// 2. Generate code
// dart run build_runner build

// 3. Connect and query
var sequelize = Sequelize().createInstance(
  PostgressConnection(url: 'postgresql://...'),
);

await sequelize.authenticate();
sequelize.addModels([Users.instance]);

var users = await Users.instance.findAll();
```

## Documentation

- **[Getting Started](./getting-started.md)** - Quick introduction and setup
- **[Installation](./installation.md)** - Detailed installation guide
- **[Models](./models.md)** - Model definitions and code generation
- **[Connections](./connections.md)** - Database connection configuration
- **[Querying](./querying.md)** - Query building and execution
- **[Examples](./examples.md)** - Complete working examples

## Resources

- [GitHub Repository](https://github.com/crazidev/sequelize_dart)
- [Changelog](./changelog.md)
- [Contributing Guide](./contributing.md)

## Need Help?

- Check the [FAQ](./faq.md) for common questions
- See [Troubleshooting](./troubleshooting.md) for solutions
- Open an issue on [GitHub](https://github.com/crazidev/sequelize_dart/issues)

Let's get started! 🚀
