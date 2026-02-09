import 'package:sequelize_orm/src/seeding/sequelize_seeding.dart';
import 'package:sequelize_orm/src/sequelize/sequelize_impl.dart';

typedef SeederLogFn = void Function(String message);

enum SyncTableMode {
  alter,
  force,
  none,
}

/// Programmatic seeding helper.
///
/// Usage:
/// ```dart
/// await sequelize.seed(seeders: Seeders.all());
/// ```
extension SequelizeSeedExtension on Sequelize {
  /// Runs the given seeders in order (ascending), with simple logs.
  ///
  /// This is intentionally an extension (instead of modifying `SequelizeInterface`)
  /// to keep the API non-breaking.
  Future<void> seed({
    required List<SequelizeSeeding> seeders,
    bool sortByOrder = true,
    SyncTableMode syncTableMode = SyncTableMode.none,
    SeederLogFn? log,
  }) async {
    final logger = log ?? (msg) => print(msg);

    switch (syncTableMode) {
      case SyncTableMode.alter:
        logger('[seed] sync(alter: true)');
        await sync(alter: true);
        break;
      case SyncTableMode.force:
        logger('[seed] sync(force: true)');
        await sync(force: true);
        break;
      case SyncTableMode.none:
        break;
    }

    final list = [...seeders];
    if (sortByOrder) {
      list.sort((a, b) => a.order.compareTo(b.order));
    }

    for (final seeder in list) {
      final name = seeder.runtimeType.toString();
      logger('[seed] start $name (${seeder.seedData.length} rows)');
      await seeder.run();
      logger('[seed] done  $name');
    }
  }
}
