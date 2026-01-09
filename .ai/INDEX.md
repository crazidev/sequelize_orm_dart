# Sequelize Dart - AI Documentation Index

This folder contains documentation to help AI agents understand and work with the Sequelize Dart codebase.

## Documentation Files

| File                                                 | Description                                               |
| ---------------------------------------------------- | --------------------------------------------------------- |
| [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md)         | Architecture, package structure, and how the system works |
| [QUERY_IMPLEMENTATION.md](./QUERY_IMPLEMENTATION.md) | Step-by-step guide to add new query methods               |
| [GENERATOR_GUIDE.md](./GENERATOR_GUIDE.md)           | How the code generator works and how to extend it         |
| [DEVELOPMENT_WORKFLOW.md](./DEVELOPMENT_WORKFLOW.md) | Build, test, and development commands                     |

## Cursor Rules

The `.cursor/rules/sequelize_dart.mdc` file contains AI rules specific to this project for use with Cursor IDE.

## Quick Start for AI Agents

### Understanding the Codebase

1. Read [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md) for architecture understanding
2. Explore `example/lib/models/` for model examples
3. Check `example/lib/models/*.g.dart` for generated code patterns

### Common Tasks

| Task                                     | Reference                                                                                        |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Add a new query method (e.g., `destroy`) | [QUERY_IMPLEMENTATION.md](./QUERY_IMPLEMENTATION.md)                                             |
| Add a new operator (e.g., `myOp`)        | [QUERY_IMPLEMENTATION.md#adding-a-new-operator](./QUERY_IMPLEMENTATION.md#adding-a-new-operator) |
| Modify generated code                    | [GENERATOR_GUIDE.md](./GENERATOR_GUIDE.md)                                                       |
| Run tests                                | [DEVELOPMENT_WORKFLOW.md#running-tests](./DEVELOPMENT_WORKFLOW.md#running-tests)                 |
| Build the project                        | [DEVELOPMENT_WORKFLOW.md](./DEVELOPMENT_WORKFLOW.md)                                             |

### Key Patterns to Know

1. **Platform Conditional Exports**: Files ending in `_dart.dart` vs `_js.dart`
2. **Generated Code**: Look for `part of` and `$ClassName` patterns
3. **Bridge Communication**: JSON-RPC over stdin/stdout
4. **Query Operators**: Extensions on `Column<T>` returning `ComparisonOperator`

### Important File Locations

```
packages/sequelize_dart/lib/src/query/query_engine/
├── query_engine_interface.dart  # Abstract interface
├── query_engine_dart.dart       # Dart VM implementation (bridge)
└── query_engine_js.dart         # JS interop implementation

packages/sequelize_dart/js/src/
├── bridge_server.ts             # Main entry point
├── handlers/                    # RPC method handlers
└── utils/queryConverter.ts      # Query option conversion

packages/sequelize_dart_generator/lib/src/
├── sequelize_model_generator.dart  # Main generator
└── generators/methods/             # Individual method generators
```

## Syntax Patterns

### Model Definition

```dart
@Table(tableName: 'users')
class Users {
  @ModelAttributes(name: 'id', type: DataType.INTEGER, primaryKey: true)
  dynamic id;

  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static $Users get instance => $Users();
}
```

### Query Usage

```dart
// Type-safe where clause
await Users.instance.findAll(
  where: (u) => and([
    u.id.gt(0),
    u.email.like('%@example.com'),
  ]),
);

// With includes
await Users.instance.findAll(
  where: (u) => u.id.eq(1),
  include: (inc) => [
    inc.posts(
      where: (p) => p.published.eq(true),
      order: [['createdAt', 'DESC']],
    ),
  ],
);
```

### Operator Extension Pattern

```dart
extension on Column<T> {
  ComparisonOperator myOp(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$myOp': value},
    );
  }
}
```

### Generator Pattern

```dart
void _generateMethod(StringBuffer buffer, String className, ...) {
  buffer.writeln('  @override');
  buffer.writeln('  Future<ReturnType> methodName({');
  buffer.writeln('    // parameters');
  buffer.writeln('  }) {');
  buffer.writeln('    // implementation');
  buffer.writeln('  }');
}
```

## Testing Approach

Tests verify SQL output by capturing queries via logging callback:

```dart
setUpAll(() async => await initTestEnvironment());
setUp(() => clearCapturedSql());

test('operator produces correct SQL', () async {
  await Users.instance.findAll(where: (u) => u.id.eq(1));
  expect(lastSql, contains('"id" = 1'));
});
```
