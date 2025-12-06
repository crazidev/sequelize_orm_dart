// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'post.model.dart';

// **************************************************************************
// SequelizeModelGenerator
// **************************************************************************

class $Post extends Model {
  static final $Post _instance = $Post._internal();

  @override
  String get name => 'Post';

  $Post._internal();

  factory $Post() {
    return _instance;
  }

  @override
  $Post define(String modelName, Object sequelize) {
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
      ModelAttributes(name: 'title', type: DataType.STRING),
      ModelAttributes(name: 'content', type: DataType.TEXT),
      ModelAttributes(name: 'userId', type: DataType.INTEGER),
      ModelAttributes(name: 'createdAt', type: DataType.DATE),
      ModelAttributes(name: 'updatedAt', type: DataType.DATE),
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
    return {'tableName': 'posts', 'underscored': true, 'timestamps': true};
  }

  Future<List<$PostValues>> findAll([Query? options]) async {
    var data = await QueryEngine().findAll(
      modelName: name,
      query: options,
      sequelize: sequelizeInstance,
      model: sequelizeModel,
    );

    return data.map((value) => $PostValues.fromJson(value)).toList();
  }

  Future<$PostValues?> findOne([Query? options]) async {
    var data = await QueryEngine().findOne(
      modelName: name,
      query: options,
      sequelize: sequelizeInstance,
      model: sequelizeModel,
    );

    return data != null ? $PostValues.fromJson(data) : null;
  }
}

class $PostValues {
  final int id;
  final String title;
  final String content;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  $PostValues({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory $PostValues.fromJson(Map<String, dynamic> json) {
    return $PostValues(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class $PostCreate {
  final String title;
  final String content;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  $PostCreate({
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
