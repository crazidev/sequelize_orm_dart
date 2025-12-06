import 'package:sequelize_dart/sequelize_dart.dart';

part 'post_details.model.g.dart';

@Table(tableName: 'post_details')
class PostDetails {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    notNull: false,
    autoIncrement: true,
  )
  dynamic id;

  @ModelAttributes(
    name: 'postId',
    type: DataType.INTEGER,
  )
  dynamic postId;

  @ModelAttributes(
    name: 'views',
    type: DataType.INTEGER,
  )
  dynamic views;

  @ModelAttributes(
    name: 'likes',
    type: DataType.INTEGER,
  )
  dynamic likes;

  @ModelAttributes(
    name: 'metadata',
    type: DataType.JSON,
  )
  dynamic metadata;

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

  static $PostDetails get instance => $PostDetails();
}

