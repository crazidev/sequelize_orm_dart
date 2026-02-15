// import 'dart:io';

// import 'package:sequelize_orm/sequelize_orm.dart';
// import 'package:sequelize_orm_example/db/models/users.model.dart';
// import 'package:test/test.dart';

// import '../test_helper.dart';

void main() {}

// void _main() {
//   setUpAll(() async {
//     await initTestEnvironment();
//   });

//   final dialect = Platform.environment['DB_TYPE']?.toLowerCase() ?? 'postgres';

//   // tearDownAll(() async {
//   //   await cleanupTestEnvironment();
//   // });

//   // setUp(() {
//   //   clearCapturedSql();
//   // });

//   group('Escaping', () {
//     test('is done properly for special characters', () async {
//       final firstName = "$dialect'\"\\n";

//       final u1 = await Users.model.create(
//         CreateUsers(
//           email: 'test@example.com',
//           firstName: firstName,
//           lastName: 'User',
//         ),
//       );

//       final u2 = await Users.model.findOne(
//         where: (user) => user.id.eq(u1.id),
//       );

//       expect(u2?.firstName, firstName);
//     });
//   });
// }
