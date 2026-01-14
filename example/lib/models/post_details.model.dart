import 'package:sequelize_dart/sequelize_dart.dart';

part 'post_details.model.g.dart';

@Table(
  tableName: 'post_details',
  underscored: true,
)
class PostDetails {
  @ColumnDefinition(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  )
  dynamic id;

  @ColumnDefinition(
    name: 'post_id',
    type: DataType.INTEGER,
  )
  dynamic postId;

  @ColumnDefinition(
    name: 'views',
    type: DataType.INTEGER,
  )
  dynamic views;

  @ColumnDefinition(
    name: 'likes',
    type: DataType.INTEGER,
  )
  dynamic likes;

  @ColumnDefinition(
    name: 'metadata',
    type: DataType.JSON,
  )
  dynamic metadata;

  static $PostDetails get instance => $PostDetails();
}
