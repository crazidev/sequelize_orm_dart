import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  // Create a user with a BIGINT phone number
  final created = await Db.users.create(CreateUsers(
    email: 'bigint_test_${DateTime.now().millisecondsSinceEpoch}@example.com',
    firstName: 'BigInt',
    lastName: 'Tester',
    phoneNumber: SequelizeBigInt('9223372036854775807'),
  ));

  print('--- Created user ---');
  print('toJson: ${created.toJson()}');
  print('phoneNumber type: ${created.phoneNumber.runtimeType}');
  print('phoneNumber value: ${created.phoneNumber?.value}');
  print('phoneNumber toBigInt: ${created.phoneNumber?.toBigInt()}');

  // Read it back
  final found = await Db.users.findOne(
    where: (u) => and([]),
  );

  print('\n--- Found user ---');
  print('toJson: ${found?.toJson()}');
  print('phoneNumber type: ${found?.phoneNumber.runtimeType}');
  print('phoneNumber value: ${found?.phoneNumber?.value}');
}
