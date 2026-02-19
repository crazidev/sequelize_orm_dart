import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  // Enum query examples

  // 1. Prefix shortcuts (e.g. isActive, notActive)
  // These are only generated when prefix/opposite is provided in @EnumPrefix
  final user1 = await Db.users.findOne(
    where: (users) => users.status.isActive,
  );
  print('Found active user (shortcut): ${user1?.firstName}');

  final user2 = await Db.users.findOne(
    where: (users) => users.status.notActive,
  );
  print('Found non-active user (shortcut): ${user2?.firstName}');

  // 2. Grouped access (eq.value, not.value)
  // Grouping reduces autocomplete clutter at the top level
  final user3 = await Db.users.findOne(
    where: (users) => users.status.eq.active,
  );
  print('Found active user (grouped): ${user3?.firstName}');

  final user4 = await Db.users.findOne(
    where: (users) => users.status.not.pending,
  );
  print('Found non-pending user (grouped): ${user4?.firstName}');

  // 3. Null checks (standard functions)
  final user5 = await Db.users.findOne(
    where: (users) => users.status.isNull(),
  );
  final user6 = await Db.users.findOne(
    where: (users) => users.status.isNotNull(),
  );
  print('Null status checks: ${user5?.firstName}, ${user6?.firstName}');

  // 4. Method-based access (type-safe)
  final user7 = await Db.users.findOne(
    where: (users) => users.status.eq(UsersStatus.active),
  );
  print('Found active user (method): ${user7?.firstName}');

  // 5. Update using raw enum
  if (user7 != null) {
    await Db.users.update(
      status: UsersStatus.inactive,
      where: (u) => u.id.eq(user7.id!),
    );
    print('Updated user status to inactive');
  }
}
