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

  @override
  Future<List<$UsersValues>> findAll(Query Function($UsersQuery) builder) {
    final query = builder($UsersQuery());
    return QueryEngine()
        .findAll(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        .then(
          (data) => data.map((value) => $UsersValues.fromJson(value)).toList(),
        );
  }

  @override
  Future<$UsersValues?> findOne(Query Function($UsersQuery) builder) {
    final query = builder($UsersQuery());
    return QueryEngine()
        .findOne(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        .then((data) => data != null ? $UsersValues.fromJson(data) : null);
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

/// Type-safe query builder for Users
class $UsersQuery {
  $UsersQuery();

  final id = TypedColumn<int>('id', DataType.INTEGER);
  final email = TypedColumn<String>('email', DataType.STRING);
  final firstName = TypedColumn<String>('firstName', DataType.STRING);
  final lastName = TypedColumn<String>('lastName', DataType.STRING);
}
