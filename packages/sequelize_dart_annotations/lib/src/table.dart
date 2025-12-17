/// Marks a class as a database table
class Table {
  /// The name of the table in the database
  final String tableName;

  /// Use snake_case for column names
  final bool underscored;

  /// Timestamps (createdAt, updatedAt)
  final bool timestamps;

  const Table({
    required this.tableName,
    this.underscored = true,
    this.timestamps = true,
  });
}
