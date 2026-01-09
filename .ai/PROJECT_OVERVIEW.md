# Sequelize Dart - Project Overview

## What is Sequelize Dart?

Sequelize Dart is a Dart ORM that provides a type-safe interface to Sequelize.js. It enables Dart applications to interact with PostgreSQL, MySQL, and MariaDB databases using Sequelize's powerful query capabilities.

## Dual Platform Architecture

The ORM supports two runtime environments with the same API:

### Dart VM (Server)

- Uses a **Node.js bridge process** running Sequelize.js
- Communication via **JSON-RPC** over stdin/stdout
- Bridge is bundled into a single JS file (`bridge_server.bundle.js`)
- No `node_modules` required at runtime

### dart2js (JavaScript)

- Uses **direct JS interop** (`dart:js_interop`)
- Calls Sequelize.js APIs directly
- No bridge overhead, native performance

## Package Structure

```
my_dart_server/
├── packages/
│   ├── sequelize_dart/               # Main ORM package
│   │   ├── lib/
│   │   │   ├── sequelize_dart.dart   # Public API exports
│   │   │   └── src/
│   │   │       ├── association/      # Association definitions
│   │   │       ├── connection/       # Database connections
│   │   │       ├── core/             # Global utilities
│   │   │       ├── model/            # Model base classes
│   │   │       ├── query/            # Query building
│   │   │       │   ├── operators/    # Query operators (eq, ne, like, etc.)
│   │   │       │   ├── query_engine/ # Query execution
│   │   │       │   └── association/  # Include builders
│   │   │       ├── sequelize/        # Sequelize instance management
│   │   │       ├── types/            # Data type definitions
│   │   │       └── utils/            # Utility functions
│   │   └── js/                       # TypeScript bridge
│   │       ├── src/
│   │       │   ├── bridge_server.ts  # Main entry point
│   │       │   ├── handlers/         # RPC method handlers
│   │       │   └── utils/            # Bridge utilities
│   │       └── bridge_server.bundle.js  # Bundled output
│   │
│   ├── sequelize_dart_annotations/   # Annotations package
│   │   └── lib/
│   │       └── src/
│   │           ├── table.dart        # @Table annotation
│   │           ├── model_attribute.dart  # @ModelAttributes
│   │           ├── has_one.dart      # @HasOne association
│   │           └── has_many.dart     # @HasMany association
│   │
│   └── sequelize_dart_generator/     # Code generator
│       └── lib/
│           └── src/
│               ├── builder.dart      # Build runner integration
│               ├── sequelize_model_generator.dart  # Main generator
│               └── generators/methods/  # Method generators
│
├── example/                          # Example application
│   ├── lib/
│   │   ├── main.dart                 # Entry point
│   │   ├── models/                   # Model definitions
│   │   └── queries.dart              # Example queries
│   └── migrations/                   # SQL migration files
│
├── test/                             # Integration tests
│   ├── operators/                    # Operator tests
│   ├── associations/                 # Association tests
│   └── test_helper.dart              # Test utilities
│
└── tools/                            # Build scripts
    ├── setup_bridge.sh               # Build bridge bundle
    ├── build.sh                      # Build dart2js output
    └── format.sh                     # Format code
```

## Key Components

### 1. Annotations (`sequelize_dart_annotations`)

Platform-independent annotations that define the model schema:

```dart
@Table(tableName: 'users', timestamps: false, underscored: true)
class Users {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  )
  dynamic id;

  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;
}
```

### 2. Code Generator (`sequelize_dart_generator`)

Generates implementation code for models:

- `$Users` - Model class with query methods
- `$UsersValues` - Data class for query results
- `$UsersColumns` - Type-safe column references
- `$UsersQuery` - Query builder with associations
- `$UsersIncludeHelper` - Type-safe include builder

### 3. Query Engine (`sequelize_dart`)

Executes queries on the appropriate platform:

- `query_engine_dart.dart` - Bridge communication
- `query_engine_js.dart` - JS interop

### 4. Bridge Server (`js/`)

Node.js process handling Sequelize.js operations:

- Receives JSON-RPC requests via stdin
- Executes Sequelize operations
- Returns results via stdout

## Data Flow

### Query Execution (Dart VM)

```
1. User calls: Users.instance.findAll(where: (u) => u.id.eq(1))

2. Generated code builds Query object with where clause

3. QueryEngine.findAll() called with model name and query

4. BridgeClient.call('findAll', {...}) sends JSON-RPC to Node.js

5. bridge_server.ts receives request, routes to handleFindAll()

6. handleFindAll() converts query, calls Sequelize model.findAll()

7. Results returned as JSON, parsed into $UsersValues objects
```

### Query Execution (dart2js)

```
1. User calls: Users.instance.findAll(where: (u) => u.id.eq(1))

2. Generated code builds Query object with where clause

3. QueryEngine.findAll() called with model name and query

4. Query options converted using _convertQueryOptions()

5. Direct call to Sequelize model.findAll(jsOptions)

6. Results converted from JS objects to $UsersValues
```

## Model Lifecycle

1. **Define Model**: User writes model with annotations
2. **Generate Code**: `build_runner` generates implementation
3. **Initialize**: `sequelize.initialize(models: [...])` registers models
4. **Associate**: Models define relationships via `associateModel()`
5. **Query**: Type-safe queries executed via generated methods

## Connection Configuration

```dart
final sequelize = Sequelize().createInstance(
  PostgressConnection(
    url: 'postgresql://user:pass@localhost:5432/db',
    logging: (sql) => print(sql),
    pool: SequelizePoolOptions(max: 10, min: 2),
  ),
);

await sequelize.initialize(models: [Users.instance, Post.instance]);
```

## Query Operators

Operators are implemented as extensions on `Column<T>`:

| Category       | Operators                                                         |
| -------------- | ----------------------------------------------------------------- |
| **Comparison** | `eq`, `ne`, `gt`, `gte`, `lt`, `lte`                              |
| **Logical**    | `and`, `or`, `not`                                                |
| **Null**       | `isNull`, `isNotNull`                                             |
| **Boolean**    | `isTrue`, `isFalse`                                               |
| **Range**      | `between`, `notBetween`                                           |
| **List**       | `in_`, `notIn`, `any`, `all`                                      |
| **String**     | `like`, `notLike`, `iLike`, `startsWith`, `endsWith`, `substring` |
| **Regex**      | `regexp`, `notRegexp`, `iRegexp`, `notIRegexp`                    |

## Current Status

### Implemented

- PostgreSQL, MySQL, MariaDB connections
- `findAll`, `findOne`, `count` queries
- All query operators
- `max`, `min`, `sum` aggregates
- `increment`, `decrement` operations
- `HasOne`, `HasMany` associations
- Include (eager loading) with nesting
- SQL logging
- Connection pooling

### Not Yet Implemented

- `create`, `update`, `destroy` mutations
- `BelongsTo`, `BelongsToMany` associations
- Transactions
- Raw queries
- Migrations
- Hooks/lifecycle events
