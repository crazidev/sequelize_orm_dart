import 'package:sequelize_orm/src/connection/core_options.dart';

/// SQLite storage mode flags.

///
/// These can be passed as a list to the [SqliteConnection] to combine them.
enum SqliteMode {
  /// Open the database in read-only mode.
  openReadOnly(1),

  /// Open the database in read-write mode.
  openReadWrite(2),

  /// Create the database if it doesn't exist.
  openCreate(4),

  /// Use full mutex locking.
  openFullMutex(8),

  /// Interpret the filename as a URI.
  openUri(16),

  /// Use shared cache mode.
  openSharedCache(32),

  /// Use private cache mode.
  openPrivateCache(64);

  final int value;
  const SqliteMode(this.value);
}

/// SQLite connection options for Sequelize Dart.
class SqliteConnection extends SequelizeCoreOptions {
  final SequelizeDialects dialect;

  /// The path to the SQLite database file.
  ///
  /// - Use ':memory:' for a memory-based temporary storage.
  /// - Use an empty string '' for a disk-based temporary storage.
  /// - Use a file path for a persistent database.
  ///
  /// Note: Temporary storages are destroyed when the connection is closed.
  /// Ensure your connection pool is configured to keep at least one connection open.
  final String storage;

  /// SQLite open mode flags.
  /// Provide a list of [SqliteMode] enums to combine them.
  final List<SqliteMode>? mode;

  /// Password for SQLCipher encrypted databases.
  final String? sqlitePassword;

  /// If set to false, SQLite will not enforce foreign keys.
  final bool foreignKeys;

  SqliteConnection({
    required this.storage,
    this.mode,
    this.sqlitePassword,
    this.foreignKeys = true,
    this.dialect = SequelizeDialects.sqlite,
    super.hoistIncludeOptions,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'storage': storage,
      'dialect': dialect.value,
      'foreignKeys': foreignKeys,
      if (mode != null && mode!.isNotEmpty)
        'mode': mode!.fold<int>(0, (prev, element) => prev | element.value),
      if (sqlitePassword != null) 'password': sqlitePassword,
    };
  }
}
