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
