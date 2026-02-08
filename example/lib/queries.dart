import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/db.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  final post = await Db.postDetails.findOne(
    where: (postDetails) => and([
      postDetails.id.eq(1),
      postDetails.metadata.key('tags').unquote().like('%dart%'),
    ]),
  );

  print(post);
}
