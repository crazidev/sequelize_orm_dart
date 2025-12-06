import 'package:sequelize_dart/sequelize_dart.dart';

part 'users.model.g.dart';

@Table(tableName: 'users')
class Users {
  @ModelAttributes(
    name: 'id',
    type: DataType.INTEGER,
    primaryKey: true,
    notNull: false,
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

  static $Users get instance => $Users();
}
