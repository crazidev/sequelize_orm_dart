// import 'package:sequelize_dart/sequelize_dart.dart';
// import 'package:sequelize_dart_example/models/users.model.dart';
// import 'package:test/test.dart';

// import '../test_helper.dart';

// void main() {
//   group('Include Query Tests', () {
//     setUpAll(() async {
//       await initTestEnvironment();
//     });

//     tearDownAll(() async {
//       await cleanupTestEnvironment();
//     });

//     setUp(() {
//       clearCapturedSql();
//     });

//     test('Basic include with type-safe syntax', () async {
//       final users = await Users.instance.findAll(
//         where: (columns) => and([columns.id.eq(1)]),
//         include: (include) => [
//           include.posts(),
//         ],
//       );

//       expect(users, isNotEmpty);
//       expect(lastSql, isNotNull);
//       expect(lastSql, contains('SELECT'));
//       // Verify that include was processed
//       expect(selectQueries.length, greaterThan(0));
//     });

//     test('Include with separate query', () async {
//       final users = await Users.instance.findAll(
//         where: (columns) => and([columns.id.eq(1)]),
//         include: (include) => [
//           include.posts(separate: true),
//         ],
//       );

//       expect(users, isNotEmpty);
//       // With separate: true, there should be multiple queries
//       expect(selectQueries.length, greaterThan(1));
//     });

//     test('Include with filtering (where clause)', () async {
//       final users = await Users.instance.findAll(
//         where: (columns) => and([columns.id.eq(1)]),
//         include: (include) => [
//           include.posts(
//             where: (postColumns) => and([
//               postColumns.title.like('%test%'),
//             ]),
//             separate: true,
//           ),
//         ],
//       );

//       expect(users, isNotEmpty);
//       // Verify that where clause was included in the query
//       final sql = selectQueries.last;
//       expect(sql, contains('WHERE'));
//     });

//     test('Include with required (INNER JOIN)', () async {
//       final users = await Users.instance.findAll(
//         include: (include) => [
//           include.posts(required: true),
//         ],
//       );

//       expect(users, isNotEmpty);
//       // With required: true, should use INNER JOIN
//       final sql = selectQueries.first;
//       expect(sql.contains('INNER JOIN') || sql.contains('JOIN'), isTrue);
//     });

//     test('Include with pagination (limit and offset)', () async {
//       final users = await Users.instance.findAll(
//         where: (columns) => and([columns.id.eq(1)]),
//         include: (include) => [
//           include.posts(
//             separate: true,
//             limit: 5,
//             offset: 0,
//           ),
//         ],
//       );

//       expect(users, isNotEmpty);
//       // Verify limit was applied
//       final sql = selectQueries.last;
//       expect(sql.contains('LIMIT') || sql.contains('limit'), isTrue);
//     });

//     test('Include with ordering', () async {
//       final users = await Users.instance.findAll(
//         where: (columns) => and([columns.id.eq(1)]),
//         include: (include) => [
//           include.posts(
//             separate: true,
//             order: [
//               ['id', 'DESC'],
//             ],
//           ),
//         ],
//       );

//       expect(users, isNotEmpty);
//       // Verify order was applied
//       final sql = selectQueries.last;
//       expect(sql.contains('ORDER BY') || sql.contains('order'), isTrue);
//     });

//     test('HasOne association include', () async {
//       final users = await Users.instance.findAll(
//         where: (columns) => and([columns.id.eq(1)]),
//         include: (include) => [
//           include.post(),
//         ],
//       );

//       expect(users, isNotEmpty);
//     });

//     test('Nested includes support infinite levels', () async {
//       // Test that nested includes can be chained infinitely
//       // This example shows the pattern (assuming Post had associations)
//       final users = await Users.instance.findAll(
//         where: (columns) => and([columns.id.eq(1)]),
//         include: (include) => [
//           include.posts(
//             separate: true,
//             // Nested includes would be added here:
//             // include: (postInclude) => [
//             //   postInclude.comments(
//             //     include: (commentInclude) => [
//             //       commentInclude.replies(), // Can nest infinitely
//             //     ],
//             //   ),
//             // ],
//           ),
//         ],
//       );

//       expect(users, isNotEmpty);
//       // Verify that nested includes are processed
//       expect(selectQueries.length, greaterThan(0));
//     });

//     test('IncludeBuilder creation and toJson', () async {
//       // Test that IncludeBuilder can be created with various options
//       final includeHelper = const $UsersIncludeHelper();
//       final include = includeHelper.posts(
//         separate: true,
//         required: false,
//         limit: 10,
//         offset: 0,
//       );
//       expect(include, isNotNull);
//       expect(include.separate, isTrue);
//       expect(include.required, isFalse);
//       expect(include.limit, equals(10));
//       expect(include.offset, equals(0));

//       // Test toJson conversion
//       final json = include.toJson();
//       expect(json, isA<Map<String, dynamic>>());
//       expect(json['association'], equals('posts'));
//       expect(json['separate'], isTrue);
//       expect(json['required'], isFalse);
//       expect(json['limit'], equals(10));
//       expect(json['offset'], equals(0));
//     });

//     test('AssociationReference col method', () async {
//       // Test that we can get column references from associations
//       // Note: Association references are still available on the query builder
//       // but the new API encourages using columns/include helpers
//       final queryBuilder = $UsersQuery();
//       final colRef = queryBuilder.posts.col('title');
//       expect(colRef, equals('posts.title'));
//     });
//   });
// }
