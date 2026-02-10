import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  final post = await Db.postDetails.findOne(
    where: (postDetails) => and([
      postDetails.id.eq(1),
      postDetails.metadata.key('tags').unquote().like('%dart%'),
    ]),
  );

  print(post?.toJson() ?? 'No post found');
}
