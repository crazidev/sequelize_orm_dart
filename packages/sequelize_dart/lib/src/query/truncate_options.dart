/// Options for Model.truncate static method
class TruncateOptions {
  /// Truncates all tables that have foreign-key references to the
  /// named table, or to any tables added to the group due to CASCADE.
  ///
  /// @default false
  final bool? cascade;

  /// Automatically restart sequences owned by columns of the truncated table
  ///
  /// @default false
  final bool? restartIdentity;

  const TruncateOptions({
    this.cascade,
    this.restartIdentity,
  });

  Map<String, dynamic> toJson() {
    return {
      if (cascade != null) 'cascade': cascade,
      if (restartIdentity != null) 'restartIdentity': restartIdentity,
    };
  }
}

/// Options for Sequelize.truncate method
class SequelizeTruncateOptions extends TruncateOptions {
  /// If set to true, the truncation will be performed without foreign key checks.
  final bool? withoutForeignKeyChecks;

  const SequelizeTruncateOptions({
    super.cascade,
    super.restartIdentity,
    this.withoutForeignKeyChecks,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (withoutForeignKeyChecks != null)
        'withoutForeignKeyChecks': withoutForeignKeyChecks,
    };
  }
}
