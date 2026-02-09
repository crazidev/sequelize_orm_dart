import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/post_details.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';

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

  @BelongsTo(Users, foreignKey: 'userId', as: 'user')
  Users? user;

  static PostModel get model => PostModel();
}
