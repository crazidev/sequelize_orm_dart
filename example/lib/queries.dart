import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  final post = await Db.users.findOne(
    where: (postDetails) => and([
    ]),
  );

  print(post?.toJson() ?? 'No post found');
}
