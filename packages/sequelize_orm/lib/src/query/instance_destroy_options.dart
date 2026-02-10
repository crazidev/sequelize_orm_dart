/// Options for instance.destroy method
class InstanceDestroyOptions {
  /// If set to true, paranoid models will actually be deleted
  final bool? force;

  const InstanceDestroyOptions({
    this.force,
  });

  Map<String, dynamic> toJson() {
    return {
      if (force != null) 'force': force,
    };
  }
}
