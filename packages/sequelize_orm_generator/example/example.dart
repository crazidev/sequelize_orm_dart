/// # Sequelize ORM Generator — Example
///
/// This generator creates type-safe model classes from annotated Dart classes
/// using `build_runner`.
///
/// ## 1. Define a model
///
/// ```dart
/// import 'package:sequelize_orm/sequelize_orm.dart';
///
/// part 'user.model.g.dart';
///
/// @Table(tableName: 'users', underscored: true)
/// abstract class User {
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
///   @HasMany(Post, foreignKey: 'user_id', as_: 'posts')
///   DataType posts = DataType.INTEGER;
/// }
/// ```
///
/// ## 2. Run code generation
///
/// ```bash
/// # Recommended
/// dart run sequelize_orm_generator:generate
///
/// # Or
/// dart run build_runner build --delete-conflicting-outputs
/// ```
///
/// ## 3. Generated output
///
/// The generator produces:
///
/// - `UserModel` — static query methods (`findAll`, `findOne`, `create`, etc.)
/// - `UserValues` — instance data with methods (`save`, `reload`, `destroy`)
/// - `CreateUser` / `UpdateUser` — type-safe DTOs
/// - `UserColumns` — column references for where clauses
/// - `UserQuery` — extends columns with association references
/// - `UserIncludeHelper` — type-safe eager loading builder
///
/// ## 4. Use the generated code
///
/// ```dart
/// // Create a user
/// final user = await User.model.create(
///   CreateUser(
///     email: 'alice@example.com',
///     firstName: 'Alice',
///     lastName: 'Smith',
///   ),
/// );
///
/// // Query with type-safe where clause
/// final found = await User.model.findOne(
///   where: (u) => u.email.eq('alice@example.com'),
/// );
///
/// // Eager-load associations
/// final withPosts = await User.model.findAll(
///   include: (i) => [i.posts()],
/// );
/// ```
library;
