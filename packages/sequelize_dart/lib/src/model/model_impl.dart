// ignore_for_file: avoid_print

import 'package:sequelize_dart/src/annotations.dart';
import 'package:sequelize_dart/src/association/association_model.dart';
import 'package:sequelize_dart/src/model/model_interface.dart';
import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/query/query_engine/query_engine.dart';
import 'package:sequelize_dart/src/sequelize/sequelize.dart';

/// Unified Model implementation for both Dart VM and dart2js.
/// Both platforms now use the bridge pattern, so the implementation is identical.
///
/// Finds all records matching the query conditions.
///
/// Returns a list of model instances that match the specified criteria.
/// If no records match, returns an empty list.
///
/// **Parameters:**
/// - `where`: Optional query conditions to filter records
/// - `include`: Optional associations to include (eager loading)
/// - `order`: Optional sorting order
/// - `group`: Optional grouping clause
/// - `limit`: Optional maximum number of records to return
/// - `offset`: Optional number of records to skip
/// - `attributes`: Optional list of attributes to select
///
/// **Returns:** A [Future] that completes with a list of model instances.
///
/// **Example:**
/// ```dart
/// // Find all users
/// final users = await Users.model.findAll();
///
/// // Find users with conditions
/// final activeUsers = await Users.model.findAll(
///   where: Users.model.email.isNotNull(),
///   limit: 10,
/// );
///
/// // Find with associations
/// final usersWithPosts = await Users.model.findAll(
///   include: [Users.model.posts],
/// );
/// ```
///
///
/// Finds a single record matching the query conditions.
///
/// Returns the first record that matches the specified criteria.
/// If no record matches, returns `null`.
///
/// **Parameters:**
/// - `where`: Optional query conditions to filter records
/// - `include`: Optional associations to include (eager loading)
/// - `order`: Optional sorting order
/// - `group`: Optional grouping clause
/// - `attributes`: Optional list of attributes to select
///
/// **Returns:** A [Future] that completes with a model instance or `null`.
///
/// **Example:**
/// ```dart
/// // Find a user by email
/// final user = await Users.model.findOne(
///   where: Users.model.email.equals('user@example.com'),
/// );
///
/// // Find with associations
/// final userWithPost = await Users.model.findOne(
///   where: Users.model.id.equals(1),
///   include: [Users.model.post],
/// );
/// ```
///
///
/// Creates a new record in the database.
///
/// Inserts a new row with the provided data and returns the created model instance.
///
/// **Parameters:**
/// - `data`: A map or model instance containing the data to insert
///
/// **Returns:** A [Future] that completes with the created model instance.
///
/// **Example:**
/// ```dart
/// // Create using a map
/// final newUser = await Users.model.create({
///   'email': 'user@example.com',
///   'firstName': 'John',
///   'lastName': 'Doe',
/// });
///
/// // Create using a Create class (if available)
/// final user = Create<Users>()
///   ..email = 'user@example.com'
///   ..firstName = 'John'
///   ..lastName = 'Doe';
/// final created = await Users.model.create(user);
/// ```
///
///
/// Counts the number of records matching the query conditions.
///
/// Returns the total count of records that match the specified criteria.
///
/// **Parameters:**
/// - `where`: Optional query conditions to filter records
///
/// **Returns:** A [Future] that completes with the count as an integer.
///
/// **Example:**
/// ```dart
/// // Count all users
/// final total = await Users.model.count();
///
/// // Count with conditions
/// final activeCount = await Users.model.count(
///   where: Users.model.email.isNotNull(),
/// );
/// ```
///
abstract class Model<T> extends ModelInterface {
  @override
  @protected
  ModelInterface define(String modelName, Object sq) {
    sequelizeInstance = sq;
    name = modelName;
    sequelize = sq as Sequelize;
    sequelizeModel = <String, dynamic>{};

    print('✅ Defining model: $modelName');
    return this;
  }

  /// Base implementation of associateModel - override in generated models
  /// Called by Sequelize.initialize() after all models are defined
  @override
  @protected
  Future<void> associateModel() async {
    // Base implementation does nothing
    // Generated model classes override this to set up associations
  }

  @override
  Future<Association> hasOne(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  }) async {
    print('✅ $name hasOne ${model.name}');

    await sequelize.bridge.call('associateModel', {
      'sourceModel': name,
      'targetModel': model.name,
      'associationType': 'hasOne',
      'options': {
        'foreignKey': foreignKey,
        'as': as,
        'sourceKey': sourceKey,
      },
    });

    return Association();
  }

  @override
  Future<Association> hasMany(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  }) async {
    print('✅ $name hasMany ${model.name}');

    await sequelize.bridge.call('associateModel', {
      'sourceModel': name,
      'targetModel': model.name,
      'associationType': 'hasMany',
      'options': {
        'foreignKey': foreignKey,
        'as': as,
        'sourceKey': sourceKey,
      },
    });

    return Association();
  }

  /// Get model attributes for Sequelize
  @override
  @protected
  List<ColumnDefinition> $getAttributes();

  /// Convert attributes to JSON for Sequelize
  @override
  @protected
  Map<String, Map<String, dynamic>> $getAttributesJson();

  /// Get model options for Sequelize
  Map<String, dynamic> getOptionsJson();

  /// {@macro findAll}
  Future<List<T>> findAll({
    covariant dynamic where,
    covariant dynamic include,
    dynamic order,
    dynamic group,
    int? limit,
    int? offset,
    QueryAttributes? attributes,
  }) {
    final query = Query.fromCallbacks(
      where: where,
      include: include,
      order: order,
      group: group,
      limit: limit,
      offset: offset,
      attributes: attributes,
    );
    return QueryEngine().findAll(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<List<T>>;
  }

  /// {@macro findOne}
  Future<T?> findOne({
    covariant dynamic where,
    covariant dynamic include,
    dynamic order,
    dynamic group,
    QueryAttributes? attributes,
  }) {
    final query = Query.fromCallbacks(
      where: where,
      include: include,
      order: order,
      group: group,
      attributes: attributes,
    );
    return QueryEngine().findOne(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<T?>;
  }

  /// {@macro create}
  Future<T> create(covariant dynamic data) {
    // Convert data to Map if it's not already (for Create classes)
    final Map<String, dynamic> dataMap = data is Map<String, dynamic>
        ? data
        : (data as dynamic).toJson();

    return QueryEngine().create(
          modelName: name,
          data: dataMap,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<T>;
  }

  /// {@macro count}
  Future<int> count({covariant dynamic where}) {
    final query = Query.fromCallbacks(where: where);
    return QueryEngine().count(
      modelName: name,
      query: query,
      sequelize: sequelizeInstance,
      model: sequelizeModel,
    );
  }

  /// Find the maximum value of a column
  Future<num?> max(covariant dynamic columnFn, {covariant dynamic where});

  /// Find the minimum value of a column
  Future<num?> min(covariant dynamic columnFn, {covariant dynamic where});

  /// Sum values of a column
  Future<num?> sum(covariant dynamic columnFn, {covariant dynamic where});
}
