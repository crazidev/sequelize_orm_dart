// import 'package:sequelize_orm_example/db/models/post.model.dart';
// import 'package:test/test.dart';

// import '../test_helper.dart';

void main() {}

// void _main() {
//   setUpAll(() async {
//     await initTestEnvironment();
//   });

//   // tearDownAll(() async {
//   //   await cleanupTestEnvironment();
//   // });

//   // setUp(() {
//   //   clearCapturedSql();
//   // });

//   test('Support increment() on instance', () async {
//     final post0 = await Post.model.create(
//       CreatePost(
//         title: 'test_post_0',
//         content: 'test_content_0',
//         views: 1,
//       ),
//     );

//     final result = await post0.increment(views: 3);

//     expect(result?.views, 4);
//   });

//   test('Support decrement() on instance', () async {
//     final post0 = await Post.model.create(
//       CreatePost(
//         title: 'test_post_0',
//         content: 'test_content_0',
//         views: 10,
//       ),
//     );

//     final result = await post0.decrement(views: 3);

//     expect(result?.views, 7);
//   });
// }
