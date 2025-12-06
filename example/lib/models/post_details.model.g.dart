// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'post_details.model.dart';

// **************************************************************************
// SequelizeModelGenerator
// **************************************************************************

class $PostDetails extends Model {
  static final $PostDetails _instance = $PostDetails._internal();

  @override
  String get name => 'PostDetails';

  $PostDetails._internal();

  factory $PostDetails() {
    return _instance;
  }

  @override
  $PostDetails define(String modelName, Object sequelize) {
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
      ModelAttributes(name: 'postId', type: DataType.INTEGER),
      ModelAttributes(name: 'views', type: DataType.INTEGER),
      ModelAttributes(name: 'likes', type: DataType.INTEGER),
      ModelAttributes(name: 'metadata', type: DataType.JSON),
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
    return {
      'tableName': 'post_details',
      'underscored': true,
      'timestamps': true,
    };
  }

  Future<List<$PostDetailsValues>> findAll([Query? options]) async {
    var data = await QueryEngine().findAll(
      modelName: name,
      query: options,
      sequelize: sequelizeInstance,
      model: sequelizeModel,
    );

    return data.map((value) => $PostDetailsValues.fromJson(value)).toList();
  }

  Future<$PostDetailsValues?> findOne([Query? options]) async {
    var data = await QueryEngine().findOne(
      modelName: name,
      query: options,
      sequelize: sequelizeInstance,
      model: sequelizeModel,
    );

    return data != null ? $PostDetailsValues.fromJson(data) : null;
  }

  /// Type-safe findAll with query builder
  Future<List<$PostDetailsValues>> findAllTyped(
    Query Function($PostDetailsQuery) builder,
  ) {
    final query = builder($PostDetailsQuery());
    return QueryEngine()
        .findAll(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        .then(
          (data) =>
              data.map((value) => $PostDetailsValues.fromJson(value)).toList(),
        );
  }

  /// Type-safe findOne with query builder
  Future<$PostDetailsValues?> findOneTyped(
    Query Function($PostDetailsQuery) builder,
  ) {
    final query = builder($PostDetailsQuery());
    return QueryEngine()
        .findOne(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        .then(
          (data) => data != null ? $PostDetailsValues.fromJson(data) : null,
        );
  }
}

class $PostDetailsValues {
  final int id;
  final int postId;
  final int views;
  final int likes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  $PostDetailsValues({
    required this.id,
    required this.postId,
    required this.views,
    required this.likes,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory $PostDetailsValues.fromJson(Map<String, dynamic> json) {
    return $PostDetailsValues(
      id: json['id'],
      postId: json['postId'],
      views: json['views'],
      likes: json['likes'],
      metadata: json['metadata'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'views': views,
      'likes': likes,
      'metadata': metadata,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class $PostDetailsCreate {
  final int postId;
  final int views;
  final int likes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  $PostDetailsCreate({
    required this.postId,
    required this.views,
    required this.likes,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'views': views,
      'likes': likes,
      'metadata': metadata,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// Type-safe query builder for PostDetails
class $PostDetailsQuery {
  $PostDetailsQuery();

  final id = TypedColumn<int>('id', DataType.INTEGER);
  final postId = TypedColumn<int>('postId', DataType.INTEGER);
  final views = TypedColumn<int>('views', DataType.INTEGER);
  final likes = TypedColumn<int>('likes', DataType.INTEGER);
  final metadata = TypedColumn<Map<String, dynamic>>('metadata', DataType.JSON);
  final createdAt = TypedColumn<DateTime>('createdAt', DataType.DATE);
  final updatedAt = TypedColumn<DateTime>('updatedAt', DataType.DATE);
}

/// Extension for type-safe queries on $PostDetails
extension $PostDetailsQueryExtension on $PostDetails {
  Future<List<$PostDetailsValues>> findAll(
    Query Function($PostDetailsQuery) builder,
  ) {
    final query = builder($PostDetailsQuery());
    return QueryEngine()
        .findAll(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        .then(
          (data) =>
              data.map((value) => $PostDetailsValues.fromJson(value)).toList(),
        );
  }

  Future<$PostDetailsValues?> findOne(
    Query Function($PostDetailsQuery) builder,
  ) {
    final query = builder($PostDetailsQuery());
    return QueryEngine()
        .findOne(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        .then(
          (data) => data != null ? $PostDetailsValues.fromJson(data) : null,
        );
  }
}
