import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';

part 'users.model.g.dart';

@Table(
  tableName: 'users',
  timestamps: false,
)
class Users {
  @PrimaryKey()
  @AutoIncrement()
  @NotNull()
  DataType id = DataType.INTEGER;

  @Validate.IsEmail('Email is not valid')
  @NotNull()
  DataType email = DataType.STRING;

  @ColumnName('first_name')
  @NotNull()
  DataType firstName = DataType.STRING;

  @ColumnName('last_name')
  DataType lastName = DataType.STRING;

  @HasOne(Post, foreignKey: 'userId', as: 'post')
  Post? post;

  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static $Users get instance => $Users();
}
