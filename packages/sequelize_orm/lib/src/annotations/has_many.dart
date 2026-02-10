class HasMany {
  final Type model;
  final String? foreignKey;
  final String? as;
  final String? sourceKey;

  const HasMany(
    this.model, {
    this.foreignKey,
    this.as,
    this.sourceKey,
  });
}
