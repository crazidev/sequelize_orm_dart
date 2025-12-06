# Getting Started

### 1. Install Dependencies

```
dart pub add sequelize_dart
```

```
dart pub add --dev sequelize_dart_generator
dart pub add --dev build_runner
```

### 2. Create a Model

Create a model file with annotations:

```dart
// lib/models/users.model.dart
import 'package:sequelize_dart/sequelize_dart.dart';

part 'users.model.g.dart';

@Table(tableName: 'users')
class Users {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  )
  dynamic id;

  @ModelAttributes(
    name: 'email',
    type: DataType.STRING,
    unique: true,
  )
  dynamic email;

  @ModelAttributes(
    name: 'firstName',
    type: DataType.STRING,
  )
  dynamic firstName;

  @ModelAttributes(
    name: 'lastName',
    type: DataType.STRING,
  )
  dynamic lastName;

  static $Users get instance => $Users();
}
```

### 3. Generate Model Code

```bash
dart run build_runner build
```

### 4. Connect to Database

```dart
import 'package:sequelize_dart/sequelize_dart.dart';

// PostgreSQL
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

// Authenticate
await sequelize.authenticate();
print('✅ Connected to database');

// Register models
sequelize.addModels([Users.instance]);
```

### 6. Query the Database

```dart
// Find all records
var allUsers = await Users.instance.findAll();

// Find with conditions
var users = await Users.instance.findAll(
  Query(
    where: equal('email', 'user@example.com'),
    order: [['id', 'DESC']],
    limit: 10,
  ),
);

// Find one record
var user = await Users.instance.findOne(
  Query(
    where: equal('id', 1),
  ),
);

// Create a record
var newUser = await Users.instance.create({
  'email': 'newuser@example.com',
  'firstName': 'John',
  'lastName': 'Doe',
});
```

### 7. Clean Up

```dart
// Close connection when done
await sequelize.close();
```
