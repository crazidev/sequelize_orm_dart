# FAQ

Frequently asked questions about Sequelize Dart.

## General Questions

### What is Sequelize Dart?

Sequelize Dart is a Dart ORM (Object-Relational Mapping) library that provides seamless integration with Sequelize.js. It offers code generation for type-safe models and works on both Dart server and dart2js platforms.

### Which databases are supported?

Sequelize Dart supports:
- PostgreSQL
- MySQL
- MariaDB

### Do I need to know Sequelize.js to use Sequelize Dart?

No, but familiarity with Sequelize.js concepts can be helpful. Sequelize Dart provides a Dart-friendly API while leveraging Sequelize.js under the hood.

### Is Sequelize Dart production-ready?

Sequelize Dart is actively developed and used in production. However, as with any software, test thoroughly in your environment before deploying to production.

## Platform Questions

### What's the difference between Dart Server and dart2js?

**Dart Server (Dart VM):**
- Uses a Node.js bridge process
- Requires bridge setup
- Has slight bridge overhead
- Works with standard Dart tooling

**dart2js:**
- Compiles to JavaScript
- Uses JS interop directly
- No bridge overhead
- Requires Node.js environment for Sequelize.js

### Which platform should I use?

- Use **Dart Server** if you're building a Dart server application
- Use **dart2js** if you need to compile to JavaScript or integrate with existing Node.js projects

### Do I need Node.js for Dart Server?

Yes, Dart Server requires Node.js to run the bridge process. Node.js v20.0 or higher is required.

### Can I use Sequelize Dart in Flutter?

Sequelize Dart is designed for server-side Dart applications. It's not suitable for Flutter mobile apps as it requires database server connections.

## Setup Questions

### Do I need to run `npm install`?

No, the bridge server is bundled into a single JavaScript file. You only need to run the setup script once:

```bash
./tools/setup_bridge.sh
```

### How do I update the bridge?

Re-run the setup script:

```bash
./tools/setup_bridge.sh [bun|pnpm|npm]
```

This will rebuild the bridge bundle with the latest dependencies.

### Can I use a different package manager?

Yes, the setup script supports:
- `bun` (recommended, fastest)
- `pnpm` (efficient)
- `npm` (default)

## Model Questions

### Why do I need code generation?

Code generation provides:
- Type-safe model classes
- Autocomplete support
- Compile-time error checking
- Better refactoring support

### Can I use models without code generation?

No, code generation is required. The generated classes (`$Users`, `$UsersValues`) provide the actual implementation.

### How do I add new fields to a model?

1. Add the field with `@ModelAttributes` annotation
2. Run code generator: `dart run build_runner build`
3. The generated classes will include the new field

### Can I use existing database tables?

Yes, just ensure your model definitions match your existing database schema. The `@ModelAttributes` name should match your database column names.

## Query Questions

### What's the difference between typed and dynamic queries?

**Typed queries:**
- Type-safe with autocomplete
- Compile-time error checking
- Better for refactoring
- Column names must be known at compile time

**Dynamic queries:**
- String-based column names
- Flexible for dynamic queries
- Useful for programmatic query building
- No compile-time checking

### When should I use typed queries vs dynamic queries?

- Use **typed queries** for most cases (recommended)
- Use **dynamic queries** when column names are determined at runtime

### Can I mix typed and dynamic queries?

Yes, you can use both approaches in the same application. Choose the appropriate approach for each use case.

### How do I do joins/associations?

Associations are handled through Sequelize.js. Currently, you can query related models separately. Full association support may be added in future versions.

## Performance Questions

### How do I optimize query performance?

1. Add database indexes on frequently queried columns
2. Use `limit` to avoid fetching large datasets
3. Configure appropriate connection pool sizes
4. Use pagination for large result sets

### What's a good connection pool size?

It depends on your workload:
- **Low traffic**: `max: 5, min: 1`
- **Medium traffic**: `max: 10, min: 2`
- **High traffic**: `max: 20, min: 5`

Monitor your database connection usage and adjust accordingly.

### Does Sequelize Dart support connection pooling?

Yes, connection pooling is built-in and configured through `SequelizePoolOptions`.

## Error Handling Questions

### How do I handle errors?

Use try/catch blocks and handle `BridgeException` specifically:

```dart
try {
  var user = await Users.instance.findOne(...);
} on BridgeException catch (e) {
  // Handle bridge errors
} catch (e) {
  // Handle other errors
}
```

### What's BridgeException?

`BridgeException` is thrown by the bridge process (Dart server only) and contains error information from Sequelize.js.

## Migration Questions

### How do I migrate from dynamic to typed queries?

Replace string-based queries with typed query callbacks:

**Before:**
```dart
where: equal('email', 'user@example.com')
```

**After:**
```dart
where: q.email.eq('user@example.com')
```

### Can I use Sequelize Dart with existing Sequelize.js code?

Sequelize Dart uses Sequelize.js under the hood, so concepts are similar, but the API is Dart-specific.

## Development Questions

### How do I contribute?

See the [Contributing](./contributing.md) guide for information on contributing to Sequelize Dart.

### Where can I report bugs?

Report bugs and issues on the GitHub repository: https://github.com/crazidev/sequelize_dart/issues

### Is there a changelog?

Yes, see [CHANGELOG.md](https://github.com/crazidev/sequelize_dart/blob/main/CHANGELOG.md) for version history and changes.

## Next Steps

- Check out [Getting Started](./getting-started.md) for a quick introduction
- See [Examples](./examples.md) for code examples
- Review [Troubleshooting](./troubleshooting.md) for common issues
