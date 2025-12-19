import 'package:sequelize_dart/sequelize_dart.dart';

part 'post_details.model.g.dart';

@Table(tableName: 'post_details', underscored: true)
class PostDetails {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    allowNull: true,
    autoIncrement: true,
  )
  dynamic id;

  @ModelAttributes(
    name: 'post_id',
    type: DataType.INTEGER,
  )
  dynamic postId;

  @ModelAttributes(
    name: 'views',
    type: DataType.INTEGER,
    allowNull: false,
  )
  dynamic views;

  @ModelAttributes(
    name: 'likes',
    type: DataType.INTEGER,
    allowNull: false,
  )
  dynamic likes;

  @ModelAttributes(
    name: 'metadata',
    type: DataType.JSON,
    allowNull: true,
  )
  dynamic metadata;

  static $PostDetails get instance => $PostDetails();
}
