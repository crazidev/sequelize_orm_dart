import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';

part 'users.model.g.dart';

@Table(
  underscored: true,
  deletedAt: TimestampOption.custom('deleted_at'),
)
abstract class Users {
  @PrimaryKey()
  @AutoIncrement()
  @NotNull()
  DataType id = DataType.INTEGER;

  @Validate.IsEmail('Email is not valid')
  @NotNull()
  DataType email = DataType.STRING;

  @ColumnName('first_name')
  @Validate.Min(4)
  @NotNull()
  DataType firstName = DataType.STRING;

  @ColumnName('last_name')
  DataType lastName = DataType.STRING;

  @ColumnName('deleted_at')
  DataType deletedAt = DataType.DATE;

  @HasOne(Post, foreignKey: 'userId', as: 'post')
  Post? post;

  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static UsersModel get model => UsersModel();
}
