// ignore_for_file: unused_local_variable

/// # Sequelize Dart -- Example
///
/// This example demonstrates the core workflow: defining models,
/// generating code, connecting to a database, and performing CRUD
/// operations.
///
/// ## Prerequisites
///
/// - **Node.js v18+** must be installed ([nodejs.org](https://nodejs.org/))
///
/// ## 1. Define a model
///
/// Create a file named `lib/models/users.model.dart`:
///
/// ```dart
/// import 'package:sequelize_orm/sequelize_orm.dart';
///
/// part 'users.model.g.dart';
///
/// @Table(tableName: 'users', underscored: true)
/// abstract class Users {
///   @PrimaryKey()
///   @AutoIncrement()
///   @NotNull()
///   DataType id = DataType.INTEGER;
///
///   @NotNull()
///   DataType email = DataType.STRING;
///
///   @ColumnName('first_name')
///   @NotNull()
///   DataType firstName = DataType.STRING;
///
///   @ColumnName('last_name')
///   DataType lastName = DataType.STRING;
///
///   static UsersModel get model => UsersModel();
/// }
/// ```
///
/// ## 2. Create a model registry
///
/// Create an empty file `lib/models/db.registry.dart`. The generator
/// uses it to produce a `Db` class that gives you access to all
/// models through a single import.
///
/// ## 3. Run code generation
///
/// ```bash
/// dart run build_runner build --delete-conflicting-outputs
/// ```
///
/// This generates `users.model.g.dart` (typed query builders, create
/// helpers, etc.) and `db.dart` (the model registry).
///
/// ## 4. Use the generated code
///
/// See the `main()` function below for the runtime usage.
library;

import 'package:sequelize_orm/sequelize_orm.dart';

Future<void> main() async {
  // ---------------------------------------------------------------
  // Connect to a database
  // ---------------------------------------------------------------
  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(
      host: 'localhost',
      port: 5432,
      database: 'my_database',
      user: 'postgres',
      password: 'postgres',
    ),
    // Pretty-print SQL queries to the console
    logging: SqlFormatter.printFormatted,
  );

  // ---------------------------------------------------------------
  // Initialize models from the generated registry
  // ---------------------------------------------------------------
  // import 'package:myapp/models/db.dart';
  //
  // await sequelize.initialize(models: Db.allModels());

  // ---------------------------------------------------------------
  // Create a record
  // ---------------------------------------------------------------
  // final newUser = await Db.users.create(
  //   CreateUsers(
  //     email: 'alice@example.com',
  //     firstName: 'Alice',
  //     lastName: 'Smith',
  //   ),
  // );
  // print('Created user #${newUser.id}');

  // ---------------------------------------------------------------
  // Find all records
  // ---------------------------------------------------------------
  // final allUsers = await Db.users.findAll();
  // for (final user in allUsers) {
  //   print('${user.firstName} ${user.lastName} <${user.email}>');
  // }

  // ---------------------------------------------------------------
  // Find one record with a where clause
  // ---------------------------------------------------------------
  // final alice = await Db.users.findOne(
  //   where: (u) => u.email.equals('alice@example.com'),
  // );
  // print('Found: ${alice?.firstName}');

  // ---------------------------------------------------------------
  // Find by primary key
  // ---------------------------------------------------------------
  // final user = await Db.users.findByPrimaryKey(1);

  // ---------------------------------------------------------------
  // Update records
  // ---------------------------------------------------------------
  // await Db.users.update(
  //   lastName: 'Johnson',
  //   where: (u) => u.id.eq(1),
  // );

  // ---------------------------------------------------------------
  // Aggregate queries
  // ---------------------------------------------------------------
  // final count = await Db.users.count();
  // print('Total users: $count');

  // ---------------------------------------------------------------
  // Eager-load associations
  // ---------------------------------------------------------------
  // final usersWithPosts = await Db.users.findAll(
  //   include: (i) => [i.posts()],
  // );

  // ---------------------------------------------------------------
  // Close the connection
  // ---------------------------------------------------------------
  await sequelize.close();
}
