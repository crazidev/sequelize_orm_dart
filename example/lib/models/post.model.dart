import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post_details.model.dart';

part 'post.model.g.dart';

@Table(
  tableName: 'posts',
  timestamps: false,
  underscored: true,
)
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

  @ModelAttributes(
    name: 'views',
    type: DataType.INTEGER,
    defaultValue: 0,
  )
  dynamic views;

  @HasOne(PostDetails, foreignKey: 'postId', as: 'postDetails')
  PostDetails? postDetails;

  static $Post get instance => $Post();
}
