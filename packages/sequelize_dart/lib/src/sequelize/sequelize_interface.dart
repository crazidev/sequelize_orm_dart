import 'package:sequelize_dart/sequelize_dart.dart';

abstract class SequelizeInterface {
  /// Creates a Sequelize instance with the given connection configuration.
  ///
  /// The [connection] parameter specifies the database connection options.
  /// The [logging] parameter is an optional callback for SQL query logging.
  ///
  /// Example:
  /// ```dart
  /// final sequelize = Sequelize().createInstance(
  ///   connection: SequelizeConnection.postgres(url: 'postgresql://...'),
  ///   logging: (sql) => print(sql),
  /// );
  /// ```
  SequelizeInterface createInstance({
    required SequelizeCoreOptions connection,
    Function(String sql)? logging,
    SequelizePoolOptions? pool,
    bool debug = false,
  });

  Future<void> authenticate();

  /// Initialize Sequelize with models
  ///
  /// This method properly sequences the initialization:
  /// 1. Waits for bridge connection
  /// 2. Defines all models in the bridge (awaited)
  /// 3. Sets up all associations (awaited)
  Future<void> initialize({required List<Model> models});

  void define(
    String name,
    Map<String, Map<String, dynamic>> attributes,
    Map<String, dynamic> options,
  );

  void addModels(List<Model> models);

  /// Synchronize all models in the database.
  ///
  /// If [force] is true, tables will be dropped and recreated.
  /// If [alter] is true, tables will be altered to match the model definition.
  Future<void> sync({bool force = false, bool alter = false});

  Future<void> close();

  /// Whether debug logging is enabled.
  bool get debug;

  /// Log a message using the configured logging function.
  void log(String message);
}
