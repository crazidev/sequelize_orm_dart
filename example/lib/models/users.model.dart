import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';

part 'users.model.g.dart';

@Table(tableName: 'users', underscored: true)
class Users {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    allowNull: true,
    autoIncrement: true,
  )
  dynamic id;

  @ModelAttributes(
    name: 'email',
    type: DataType.STRING,
  )
  dynamic email;

  @ModelAttributes(
    name: 'firstName',
    type: DataType.STRING,
  )
  dynamic firstName;

  @ModelAttributes(
    name: 'lastName',
    type: DataType.STRING,
  )
  dynamic lastName;

  @HasOne(Post, foreignKey: 'userId', as: 'post')
  Post? post;

  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static $Users get instance => $Users();
}
