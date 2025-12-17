import 'package:sequelize_dart/sequelize_dart.dart';

part 'post.model.g.dart';

@Table(tableName: 'posts', timestamps: false, underscored: true)
class Post {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    notNull: false,
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
    name: 'userId',
    type: DataType.INTEGER,
  )
  dynamic userId;

  @ModelAttributes(
    name: 'createdAt',
    type: DataType.DATE,
  )
  dynamic createdAt;

  @ModelAttributes(
    name: 'updatedAt',
    type: DataType.DATE,
  )
  dynamic updatedAt;

  static $Post get instance => $Post();
}
