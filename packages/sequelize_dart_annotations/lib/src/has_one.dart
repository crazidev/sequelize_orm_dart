class HasOne {
  final Type model;
  final String? foreignKey;
  final String? as;
  final String? sourceKey;
  final Map<String, dynamic>? inverse;

  const HasOne(
    this.model, {
    this.foreignKey,
    this.as,
    this.sourceKey,
    this.inverse,
  });
}
