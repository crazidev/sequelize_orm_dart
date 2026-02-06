/// Options for Model.restore static method
class RestoreOptions {
  /// If set to true, restore will find all records within the where parameter
  /// and will execute before/after bulkRestore hooks on each row
  final bool? individualHooks;

  /// How many rows to undelete
  final int? limit;

  const RestoreOptions({
    this.individualHooks,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    return {
      if (individualHooks != null) 'individualHooks': individualHooks,
      if (limit != null) 'limit': limit,
    };
  }
}
