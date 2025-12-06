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
