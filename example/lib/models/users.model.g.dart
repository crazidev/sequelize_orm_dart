// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'users.model.dart';

// **************************************************************************
// SequelizeModelGenerator
// **************************************************************************

class $Users extends Model {
  static final $Users _instance = $Users._internal();

  @override
  String get name => 'Users';

  $Users._internal();

  factory $Users() {
    return _instance;
  }

  @override
  $Users define(String modelName, Object sequelize) {
    super.define(modelName, sequelize);
    return this;
  }

  @override
  List<ModelAttributes> getAttributes() {
    return [
      ModelAttributes(
        name: 'id',
        type: DataType.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      ),
      ModelAttributes(name: 'email', type: DataType.STRING),
      ModelAttributes(name: 'firstName', type: DataType.STRING),
      ModelAttributes(name: 'lastName', type: DataType.STRING),
    ];
  }

  @override
  Map<String, Map<String, dynamic>> getAttributesJson() {
    final map = {
      for (var item in getAttributes())
        item.name: {
          'type': item.type.name,
          'notNull': item.notNull,
          'primaryKey': item.primaryKey,
          'autoIncrement': item.autoIncrement,
          'defaultValue': item.defaultValue,
        },
    };

    return map;
  }

  @override
  Map<String, dynamic> getOptionsJson() {
    return {'tableName': 'users', 'underscored': true, 'timestamps': true};
  }

  Future<List<$UsersValues>> findAll([Query? options]) async {
    var data = await QueryEngine().findAll(
      modelName: name,
      query: options,
      sequelize: sequelizeInstance,
      model: sequelizeModel,
    );

    return data.map((value) => $UsersValues.fromJson(value)).toList();
  }

  Future<$UsersValues?> findOne([Query? options]) async {
    var data = await QueryEngine().findOne(
      modelName: name,
      query: options,
      sequelize: sequelizeInstance,
      model: sequelizeModel,
    );

    return data != null ? $UsersValues.fromJson(data) : null;
  }
}

class $UsersValues {
  final int id;
  final String email;
  final String firstName;
  final String lastName;

  $UsersValues({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory $UsersValues.fromJson(Map<String, dynamic> json) {
    return $UsersValues(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class $UsersCreate {
  final String email;
  final String firstName;
  final String lastName;

  $UsersCreate({
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'firstName': firstName, 'lastName': lastName};
  }
}
