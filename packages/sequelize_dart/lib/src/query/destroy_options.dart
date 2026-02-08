/// Options for Model.destroy static method
class DestroyOptions {
  /// Delete instead of setting deletedAt to current timestamp (only applicable if `paranoid` is enabled)
  ///
  /// @default false
  final bool? force;

  /// How many rows to delete
  final int? limit;

  /// If set to true, destroy will SELECT all records matching the where parameter
  /// and will execute before/after destroy hooks on each row
  ///
  /// @default false
  final bool? individualHooks;

  const DestroyOptions({
    this.force,
    this.limit,
    this.individualHooks,
  });

  Map<String, dynamic> toJson() {
    return {
      if (force != null) 'force': force,
      if (limit != null) 'limit': limit,
      if (individualHooks != null) 'individualHooks': individualHooks,
    };
  }
}
