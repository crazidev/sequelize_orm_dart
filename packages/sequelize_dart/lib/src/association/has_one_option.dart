class HasOneOption {
  final String foreignKey;
  final String as;
  final String? sourceKey;

  HasOneOption({required this.foreignKey, required this.as, this.sourceKey});

  Map<String, dynamic> toJson() {
    return {
      'foreignKey': foreignKey,
      'as': as,
      'sourceKey': sourceKey,
    };
  }
}
