# Examples

This page contains complete, working examples demonstrating common use cases with Sequelize Dart.

## Basic CRUD Operations

### Create, Read, Update, Delete

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'models/users.model.dart';

Future<void> main() async {
  // Setup connection
  var sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: 'postgresql://postgres:postgres@localhost:5432/myapp',
      ssl: false,
    ),
  );

  await sequelize.authenticate();
  sequelize.addModels([Users.instance]);

  // CREATE - Add a new user
  var newUser = await Users.instance.create({
    'email': 'john.doe@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
  });
  print('Created user: ${newUser.email}');

  // READ - Find all users
  var allUsers = await Users.instance.findAll();
  print('Total users: ${allUsers.length}');

  // READ - Find one user
  var user = await Users.instance.findOne(
    Query(where: equal('email', 'john.doe@example.com')),
  );
  print('Found user: ${user?.email}');

  // Note: Update and Delete operations are handled through Sequelize.js
  // and can be accessed via raw queries if needed

  await sequelize.close();
}
```

## Typed Query Examples

### Simple Filtering

```dart
// Find users with ID greater than 1
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.gt(1),
    order: [[q.id, 'DESC']],
  ),
);
```

### Complex Conditions

```dart
// Find users with complex conditions
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.gt(1)
      .or(q.email.like('crazidev%'))
      .and(q.firstName.isNotNull()),
    order: [
      [q.lastName, 'ASC'],
      [q.firstName, 'ASC'],
    ],
    limit: 20,
  ),
);
```

### List Operations

```dart
// Find users with IDs in a list
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.in_([1, 2, 3, 4, 5]),
    order: [[q.id, 'DESC']],
  ),
);
```

### Range Queries

```dart
// Find users with ID between 10 and 100
var users = await Users.instance.findAll(
  (q) => Query(
    where: q.id.between(10, 100),
    order: [[q.id, 'ASC']],
  ),
);
```

## Dynamic Query Examples

### Building Queries Programmatically

```dart
// Build query based on user input
String? emailFilter = getUserInput();
List<QueryOperator> conditions = [];

if (emailFilter != null) {
  conditions.add(equal('email', emailFilter));
}

var users = await Users.instance.findAll(
  Query(
    where: conditions.isNotEmpty ? and(conditions) : null,
  ),
);
```

### Dynamic Sorting

```dart
// Sort by user-selected column
String sortColumn = getUserPreference(); // 'lastName' or 'firstName'
List<String> allowedColumns = ['id', 'email', 'firstName', 'lastName'];

if (!allowedColumns.contains(sortColumn)) {
  sortColumn = 'id'; // Default
}

var users = await Users.instance.findAll(
  Query(
    order: [[sortColumn, 'ASC']],
  ),
);
```

## Pagination

### Basic Pagination

```dart
Future<List<$UsersValues>> getUsersPage(int page, int pageSize) async {
  return await Users.instance.findAll(
    Query(
      order: [['id', 'DESC']],
      limit: pageSize,
      offset: (page - 1) * pageSize,
    ),
  );
}

// Usage
var page1 = await getUsersPage(1, 10);
var page2 = await getUsersPage(2, 10);
```

### Pagination with Total Count

```dart
// Note: Total count requires a separate query
Future<Map<String, dynamic>> getUsersPaginated(int page, int pageSize) async {
  var users = await Users.instance.findAll(
    Query(
      order: [['id', 'DESC']],
      limit: pageSize,
      offset: (page - 1) * pageSize,
    ),
  );

  // Get total count (requires separate query or raw SQL)
  var allUsers = await Users.instance.findAll();
  var total = allUsers.length;

  return {
    'data': users,
    'total': total,
    'page': page,
    'pageSize': pageSize,
    'totalPages': (total / pageSize).ceil(),
  };
}
```

## Error Handling

### Basic Error Handling

```dart
try {
  var user = await Users.instance.findOne(
    Query(where: equal('id', 999)),
  );

  if (user == null) {
    print('User not found');
  } else {
    print('Found user: ${user.email}');
  }
} on BridgeException catch (e) {
  print('Bridge error: ${e.message}');
  print('Original error: ${e.originalError}');
  if (e.sql != null) {
    print('SQL: ${e.sql}');
  }
} catch (e) {
  print('Unexpected error: $e');
}
```

### Retry Logic

```dart
Future<$UsersValues?> findUserWithRetry(int id, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await Users.instance.findOne(
        Query(where: equal('id', id)),
      );
    } on BridgeException catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 1));
    }
  }
  return null;
}
```

## Connection Pooling

### Optimized Pool Configuration

```dart
var sequelize = Sequelize().createInstance(
  PostgressConnection(
    url: 'postgresql://user:password@localhost:5432/dbname',
    ssl: false,
    pool: SequelizePoolOptions(
      max: 20,        // High traffic
      min: 5,         // Keep connections ready
      idle: 10000,    // 10 seconds
      acquire: 60000, // 60 seconds max wait
      evict: 1000,    // Check every second
    ),
  ),
);
```

## Concurrent Queries

### Parallel Execution

```dart
Future<void> fetchMultipleUsers() async {
  // Execute multiple queries in parallel
  var futures = [
    Users.instance.findAll(Query(where: equal('id', 1))),
    Users.instance.findAll(Query(where: equal('id', 2))),
    Users.instance.findAll(Query(where: equal('id', 3))),
  ];

  var results = await Future.wait(futures);
  print('Fetched ${results.length} user sets');
}
```

### Sequential Execution

```dart
Future<void> processUsersSequentially() async {
  var users = await Users.instance.findAll();
  
  for (var user in users) {
    // Process each user sequentially
    await processUser(user);
  }
}
```

## Working with Multiple Models

### Multiple Model Registration

```dart
import 'models/users.model.dart';
import 'models/posts.model.dart';
import 'models/comments.model.dart';

Future<void> setupModels() async {
  var sequelize = Sequelize().createInstance(
    PostgressConnection(url: '...'),
  );

  await sequelize.authenticate();

  // Register all models
  sequelize.addModels([
    Users.instance,
    Posts.instance,
    Comments.instance,
  ]);
}
```

### Cross-Model Queries

```dart
// Find users and their related posts (conceptual example)
// Note: Associations are handled through Sequelize.js
// This is a simplified example

var users = await Users.instance.findAll();
for (var user in users) {
  // In a real scenario, you'd use associations
  // For now, query posts separately
  var userPosts = await Posts.instance.findAll(
    Query(where: equal('userId', user.id)),
  );
  print('User ${user.email} has ${userPosts.length} posts');
}
```

## Environment-Based Configuration

### Using Environment Variables

```dart
import 'dart:io';

Future<Sequelize> createSequelizeInstance() async {
  var dbUrl = Platform.environment['DATABASE_URL'] ?? 
              'postgresql://localhost:5432/myapp';
  var sslEnabled = Platform.environment['DB_SSL'] == 'true';

  return Sequelize().createInstance(
    PostgressConnection(
      url: dbUrl,
      ssl: sslEnabled,
      logging: (String sql) {
        if (Platform.environment['DEBUG'] == 'true') {
          print(sql);
        }
      },
      pool: SequelizePoolOptions(
        max: int.tryParse(Platform.environment['DB_POOL_MAX'] ?? '10') ?? 10,
        min: int.tryParse(Platform.environment['DB_POOL_MIN'] ?? '2') ?? 2,
      ),
    ),
  );
}
```

## Complete Application Example

```dart
import 'package:sequelize_dart/sequelize_dart.dart';
import 'models/users.model.dart';

class UserService {
  late Sequelize sequelize;

  Future<void> initialize() async {
    sequelize = Sequelize().createInstance(
      PostgressConnection(
        url: 'postgresql://postgres:postgres@localhost:5432/myapp',
        ssl: false,
        logging: (String sql) => false,
        pool: SequelizePoolOptions(
          max: 10,
          min: 2,
          idle: 10000,
          acquire: 60000,
          evict: 1000,
        ),
      ),
    );

    await sequelize.authenticate();
    sequelize.addModels([Users.instance]);
  }

  Future<List<$UsersValues>> getAllUsers() async {
    return await Users.instance.findAll(
      Query(order: [['id', 'DESC']]),
    );
  }

  Future<$UsersValues?> getUserByEmail(String email) async {
    return await Users.instance.findOne(
      Query(where: equal('email', email)),
    );
  }

  Future<$UsersValues> createUser({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    return await Users.instance.create({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  Future<void> close() async {
    await sequelize.close();
  }
}

Future<void> main() async {
  var service = UserService();
  
  try {
    await service.initialize();
    
    // Create a user
    var newUser = await service.createUser(
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
    );
    print('Created: ${newUser.email}');
    
    // Find user
    var user = await service.getUserByEmail('test@example.com');
    print('Found: ${user?.email}');
    
    // Get all users
    var allUsers = await service.getAllUsers();
    print('Total users: ${allUsers.length}');
    
  } finally {
    await service.close();
  }
}
```

## Best Practices

1. **Always close connections** - Use try/finally to ensure connections are closed
2. **Handle errors gracefully** - Catch and handle `BridgeException` appropriately
3. **Use connection pooling** - Configure appropriate pool sizes for your workload
4. **Validate input** - Always validate user input when building dynamic queries
5. **Use typed queries** - Prefer typed queries for better type safety and autocomplete
6. **Index your database** - Ensure columns used in `where` clauses are indexed

## Next Steps

- Learn about [Models](./models.md) for model definitions
- Explore [Querying](./querying.md) for query capabilities
- Check out [API Reference](./api-reference.md) for detailed API documentation
