typedef SeederCreateFn<TCreate> = Future<dynamic> Function(TCreate data);

/// Base class for type-safe seeders.
///
/// `TCreate` should be the generated `Create<Model>` type for the model you want
/// to seed (e.g. `CreatePost`).
///
/// To keep seed data model-safe and avoid runtime lookups, each seeder provides a
/// typed `create` function (typically a tear-off like `Db.post.create`).
abstract class SequelizeSeeding<TCreate> {
  /// Ordering when running multiple seeders (ascending).
  int get order => 0;

  /// The data rows to seed.
  List<TCreate> get seedData;

  /// The create function for the target model (e.g. `Db.post.create`).
  SeederCreateFn<TCreate> get create;

  /// Execute this seeder.
  Future<void> run() async {
    for (final item in seedData) {
      await create(item);
    }
  }
}
