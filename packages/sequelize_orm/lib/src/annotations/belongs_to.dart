/// Defines an association where the foreign key exists on the source (this)
/// model, pointing to the target model's primary key.
///
/// {@category Associations}
class BelongsTo {
  final Type model;

  /// The foreign key on the source model.
  ///
  /// Example: `postId`
  final String? foreignKey;

  /// The name of the association (defaults to the annotated field name).
  final String? as;

  /// The attribute on the target model that the foreign key references.
  ///
  /// If not provided, Sequelize defaults to the target model primary key.
  final String? targetKey;

  const BelongsTo(
    this.model, {
    this.foreignKey,
    this.as,
    this.targetKey,
  });
}
