import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/models/post.model.dart';
import 'package:sequelize_dart_example/db/models/users.model.dart';

part 'post_details.model.g.dart';

@Table(
  tableName: 'post_details',
  underscored: true,
)
abstract class PostDetails {
  @ColumnDefinition(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  )
  dynamic id;

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

  @ColumnDefinition(
    name: 'postId',
    type: DataType.INTEGER,
  )
  dynamic postId;

  @ColumnDefinition(
    name: 'userId',
    type: DataType.INTEGER,
  )
  dynamic userId;

  @BelongsTo(Post, foreignKey: 'postId', as: 'post')
  Post? post;

  @BelongsTo(Users, foreignKey: 'userId', as: 'user')
  Users? user;

  static PostDetailsModel get model => PostDetailsModel();
}
