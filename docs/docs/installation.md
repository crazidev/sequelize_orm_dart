# Installation

This guide covers the installation and setup process for Sequelize Dart.

## Package Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  sequelize_dart:
    path: ../packages/sequelize_dart
  sequelize_dart_annotations:
    path: ../packages/sequelize_dart_annotations

dev_dependencies:
  sequelize_dart_generator:
    path: ../packages/sequelize_dart_generator
  build_runner: ^2.10.4
```

Then run:

```bash
dart pub get
```

## Platform-Specific Setup

### Dart Server (Dart VM)

When running on Dart server, Sequelize Dart requires a Node.js bridge to execute Sequelize.js operations.

#### Bridge Setup

1. **Build the bridge server bundle** (one-time setup):

```bash
./tools/setup_bridge.sh [bun|pnpm|npm]
```

This script:
- Installs Node.js dependencies (Sequelize.js and related packages)
- Bundles everything into a single JavaScript file: `packages/sequelize_dart/js/bridge_server.bundle.js`
- Makes the bridge portable (no `npm install` required for end-users)

**Package Manager Options:**
- `bun` - Fastest option (recommended if available)
- `pnpm` - Efficient disk usage
- `npm` - Default option

2. **The bridge is automatically used** when you create a Sequelize instance on Dart server. No additional configuration needed.

#### How It Works

- A singleton Node.js process is spawned when you first create a Sequelize instance
- Communication happens via JSON-RPC over stdin/stdout
- The bridge process manages all Sequelize.js operations
- Connection pooling is handled by Sequelize.js in the bridge

### dart2js (JavaScript Compilation)

When compiling to JavaScript with `dart2js`, **no setup is required**.

The library uses `dart:js_interop` to directly call Sequelize.js APIs, providing:
- Native performance (no bridge overhead)
- Direct function calls
- Same API as Dart server

**To compile:**

```bash
dart compile js lib/main.dart -o main.js
node main.js
```

## Code Generation Setup

Sequelize Dart uses code generation to create type-safe model implementations.

### 1. Create Model Files

Create your model files with annotations (see [Models](./models.md) for details):

```dart
// lib/models/users.model.dart
import 'package:sequelize_dart/sequelize_dart.dart';

part 'users.model.g.dart';

@Table(tableName: 'users')
class Users {
  // ... model definition
}
```

### 2. Run Code Generator

Generate the model implementations:

```bash
# One-time generation
dart run build_runner build

# Watch mode (regenerates on file changes)
dart run build_runner watch
```

This creates `users.model.g.dart` with:
- `$Users` - The generated model class
- `$UsersValues` - Type-safe value class
- `$UsersCreate` - Type-safe create class

### 3. Use Generated Models

```dart
// Access the generated model instance
var users = Users.instance; // Returns $Users instance

// Use type-safe queries
var userList = await Users.instance.findAll();
// Returns List<$UsersValues>
```

## Database Setup

### PostgreSQL

1. **Install PostgreSQL** (if not already installed)
2. **Create a database**:

```sql
CREATE DATABASE myapp;
```

3. **Use connection URL**:

```dart
PostgressConnection(
  url: 'postgresql://user:password@localhost:5432/myapp',
  ssl: false,
)
```

### MySQL

1. **Install MySQL** (if not already installed)
2. **Create a database**:

```sql
CREATE DATABASE myapp;
```

3. **Use connection URL**:

```dart
MysqlConnection(
  url: 'mysql://user:password@localhost:3306/myapp',
  ssl: false,
)
```

### MariaDB

1. **Install MariaDB** (if not already installed)
2. **Create a database**:

```sql
CREATE DATABASE myapp;
```

3. **Use connection URL**:

```dart
MariadbConnection(
  url: 'mariadb://user:password@localhost:3306/myapp',
  ssl: false,
)
```

## Running Migrations

SQL migration files are provided in the `example/migrations/` directory:

- **MySQL**: `create_tables_mysql.sql`, `seed_data_mysql.sql`
- **PostgreSQL**: `create_tables_postgres.sql`, `seed_data_postgres.sql`

Run migrations manually:

```bash
# MySQL
mysql -u root -p dbname < example/migrations/create_tables_mysql.sql

# PostgreSQL
psql -U postgres -d dbname -f example/migrations/create_tables_postgres.sql
```

## Verification

Test your installation:

```dart
import 'package:sequelize_dart/sequelize_dart.dart';

Future<void> main() async {
  var sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: 'postgresql://user:password@localhost:5432/dbname',
      ssl: false,
    ),
  );

  try {
    await sequelize.authenticate();
    print('✅ Connection successful!');
  } catch (e) {
    print('❌ Connection failed: $e');
  } finally {
    await sequelize.close();
  }
}
```

## Troubleshooting

### Bridge Setup Issues

- **Error: "Failed to start bridge"**
  - Ensure Node.js is installed: `node --version`
  - Re-run the setup script: `./tools/setup_bridge.sh`
  - Check that the bundle file exists: `packages/sequelize_dart/js/bridge_server.bundle.js`

### Code Generation Issues

- **Error: "No models found"**
  - Ensure your model files have the `part` directive: `part 'model.g.dart';`
  - Check that annotations are properly imported
  - Verify `build_runner` is in `dev_dependencies`

- **Generated files not updating**
  - Delete generated files and regenerate: `dart run build_runner build --delete-conflicting-outputs`

### Database Connection Issues

- **Connection refused**
  - Verify database server is running
  - Check connection URL format
  - Ensure firewall allows connections

- **Authentication failed**
  - Verify username and password
  - Check database user permissions

For more help, see the [Troubleshooting](./troubleshooting.md) guide.
