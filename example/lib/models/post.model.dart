import 'package:sequelize_dart/sequelize_dart.dart';

part 'post.model.g.dart';

@Table(tableName: 'posts', timestamps: false, underscored: true)
class Post {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    allowNull: true,
    autoIncrement: true,
  )
  dynamic id;

  @ModelAttributes(
    name: 'title',
    type: DataType.STRING,
  )
  dynamic title;

  @ModelAttributes(
    name: 'content',
    type: DataType.TEXT,
  )
  dynamic content;

  @ModelAttributes(
    name: 'user_id',
    type: DataType.INTEGER,
  )
  dynamic userId;

  static $Post get instance => $Post();
}
