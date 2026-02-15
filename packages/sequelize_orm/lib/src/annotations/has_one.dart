/// Defines a one-to-one association where the foreign key exists on the
/// target model.
///
/// {@category Associations}
class HasOne {
  final Type model;
  final String? foreignKey;
  final String? as;
  final String? sourceKey;

  const HasOne(
    this.model, {
    this.foreignKey,
    this.as,
    this.sourceKey,
  });
}
