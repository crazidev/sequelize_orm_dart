# Connections

Sequelize Dart supports multiple database dialects: PostgreSQL, MySQL, and MariaDB. This guide covers connection configuration and options.

## Connection Types

### PostgreSQL

PostgreSQL is a powerful, open-source relational database system.

```dart
import 'package:sequelize_dart/sequelize_dart.dart';

var sequelize = Sequelize().createInstance(
  PostgressConnection(
    url: 'postgresql://user:password@localhost:5432/dbname',
    ssl: false,
    logging: (String sql) => print(sql),
    pool: SequelizePoolOptions(
      max: 10,
      min: 2,
      idle: 10000,
      acquire: 60000,
      evict: 1000,
    ),
  ),
);
```

### MySQL

MySQL is a popular open-source relational database.

```dart
var sequelize = Sequelize().createInstance(
  MysqlConnection(
    url: 'mysql://user:password@localhost:3306/dbname',
    ssl: false,
    logging: (String sql) => print(sql),
    pool: SequelizePoolOptions(
      max: 10,
      min: 2,
      idle: 10000,
      acquire: 60000,
      evict: 1000,
    ),
  ),
);
```

### MariaDB

MariaDB is a community-developed fork of MySQL.

```dart
var sequelize = Sequelize().createInstance(
  MariadbConnection(
    url: 'mariadb://user:password@localhost:3306/dbname',
    ssl: false,
    logging: (String sql) => print(sql),
    pool: SequelizePoolOptions(
      max: 10,
      min: 2,
      idle: 10000,
      acquire: 60000,
      evict: 1000,
    ),
  ),
);
```

## Connection URL Format

The connection URL follows this format:

```
dialect://username:password@host:port/database
```

### Examples

```dart
// PostgreSQL
'postgresql://postgres:mypassword@localhost:5432/mydb'

// MySQL
'mysql://root:password@localhost:3306/mydb'

// MariaDB
'mariadb://user:pass@localhost:3306/mydb'

// With special characters in password
'postgresql://user:p%40ssw0rd@localhost:5432/mydb' // @ encoded as %40
```

## Connection Options

### SSL Configuration

Enable SSL for secure connections:

```dart
PostgressConnection(
  url: 'postgresql://user:password@host:5432/dbname',
  ssl: true, // Enable SSL
)
```

For advanced SSL configuration, you may need to configure SSL at the database level or use connection pooling with SSL certificates.

### Logging

Control SQL query logging:

```dart
// Log all queries
logging: (String sql) => print(sql),

// Log only errors
logging: (String sql) {
  if (sql.contains('ERROR')) {
    print(sql);
  }
},

// Disable logging
logging: (String sql) => false,
```

### Connection Pooling

Configure connection pooling for better performance and concurrency:

```dart
pool: SequelizePoolOptions(
  max: 10,        // Maximum connections in pool
  min: 2,         // Minimum connections in pool
  idle: 10000,    // Idle timeout in milliseconds
  acquire: 60000, // Maximum time to get connection (ms)
  evict: 1000,    // Check for idle connections (ms)
)
```

**Pool Options Explained:**

- `max` - Maximum number of connections in the pool. Increase for high-traffic applications.
- `min` - Minimum number of connections to maintain. Keeps connections ready for immediate use.
- `idle` - Maximum time (ms) a connection can be idle before being released.
- `acquire` - Maximum time (ms) to wait when acquiring a connection from the pool.
- `evict` - Interval (ms) to check for idle connections that should be evicted.

**Recommended Settings:**

- **Low traffic**: `max: 5, min: 1`
- **Medium traffic**: `max: 10, min: 2`
- **High traffic**: `max: 20, min: 5`

## Authentication

After creating a connection, authenticate to verify connectivity:

```dart
var sequelize = Sequelize().createInstance(
  PostgressConnection(url: '...'),
);

try {
  await sequelize.authenticate();
  print('✅ Connection successful!');
} catch (e) {
  print('❌ Connection failed: $e');
}
```

## Registering Models

After authentication, register your models:

```dart
await sequelize.authenticate();

// Register models
sequelize.addModels([
  Users.instance,
  Posts.instance,
  Comments.instance,
]);
```

Models must be registered before you can query them.

## Closing Connections

Always close connections when done to free up resources:

```dart
await sequelize.close();
```

This closes all connections in the pool and shuts down the bridge process (on Dart server).

## Complete Example

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'models/users.model.dart';
import 'models/posts.model.dart';

Future<void> main() async {
  // Create connection
  var sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: 'postgresql://postgres:postgres@localhost:5432/myapp',
      ssl: false,
      logging: (String sql) => print('[SQL] $sql'),
      pool: SequelizePoolOptions(
        max: 10,
        min: 2,
        idle: 10000,
        acquire: 60000,
        evict: 1000,
      ),
    ),
  );

  try {
    // Authenticate
    await sequelize.authenticate();
    print('✅ Connected to database');

    // Register models
    sequelize.addModels([
      Users.instance,
      Posts.instance,
    ]);

    // Use models...
    var users = await Users.instance.findAll();
    print('Found ${users.length} users');

  } catch (e) {
    print('Error: $e');
  } finally {
    // Always close connection
    await sequelize.close();
    print('✅ Connection closed');
  }
}
```

## Error Handling

Handle connection errors gracefully:

```dart
try {
  await sequelize.authenticate();
} on BridgeException catch (e) {
  // Bridge-specific errors (Dart server only)
  print('Bridge error: ${e.message}');
  print('Original error: ${e.originalError}');
  if (e.sql != null) {
    print('SQL: ${e.sql}');
  }
} catch (e) {
  print('Connection error: $e');
}
```

## Environment Variables

For production, use environment variables for connection strings:

```dart
import 'dart:io';

var dbUrl = Platform.environment['DATABASE_URL'] ?? 
            'postgresql://localhost:5432/myapp';

var sequelize = Sequelize().createInstance(
  PostgressConnection(
    url: dbUrl,
    ssl: Platform.environment['DB_SSL'] == 'true',
  ),
);
```

## Database-Specific Features

### PostgreSQL

- Supports JSONB data type
- Advanced operators (regexp, ilike, etc.)
- Full-text search capabilities

### MySQL / MariaDB

- Similar feature sets
- Slight differences in data types
- Some operators may differ

## Troubleshooting

### Connection Refused

- Verify database server is running
- Check host and port are correct
- Ensure firewall allows connections

### Authentication Failed

- Verify username and password
- Check database user permissions
- Ensure database exists

### Pool Exhausted

- Increase `max` pool size
- Check for connection leaks (not closing connections)
- Reduce `idle` timeout

For more help, see the [Troubleshooting](./troubleshooting.md) guide.

## Next Steps

- Learn about [Querying](./querying.md) to query your database
- Explore [Models](./models.md) for model definitions
- Check out [Examples](./examples.md) for common patterns
