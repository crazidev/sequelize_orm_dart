import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post_details.model.dart';

part 'post.model.g.dart';

@Table(
  tableName: 'posts',
  timestamps: false,
  underscored: true,
)
abstract class Post {
  @PrimaryKey()
  @AutoIncrement()
  DataType id = DataType.INTEGER;

  DataType title = DataType.STRING;

  DataType content = DataType.STRING;

  @ColumnName('user_id')
  DataType userId = DataType.INTEGER;

  @Default(0)
  DataType views = DataType.INTEGER;

  @HasOne(PostDetails, foreignKey: 'postId', as: 'postDetails')
  PostDetails? postDetails;

  static PostModel get instance => PostModel();
}
