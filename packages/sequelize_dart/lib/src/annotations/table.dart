import 'package:meta/meta_meta.dart';

/// An object with two attributes, `singular` and `plural`, which are used when this model is associated to others.
class ModelNameOption {
  final String singular;
  final String plural;

  const ModelNameOption({
    required this.singular,
    required this.plural,
  });

  Map<String, String> toJson() {
    return {
      'singular': singular,
      'plural': plural,
    };
  }
}

/// Options for timestamp columns (createdAt, updatedAt, deletedAt).
/// Can disable the timestamp or customize the column name.
class TimestampOption {
  /// Whether the timestamp is enabled
  final bool enable;

  /// Custom column name. If not provided, uses the default name.
  final String? columnName;

  /// Create a TimestampOption that disables the timestamp
  const TimestampOption.disabled() : enable = false, columnName = null;

  /// Create a TimestampOption with a custom column name
  const TimestampOption.custom(this.columnName) : enable = true;

  /// Create a TimestampOption that enables with default name
  const TimestampOption.enabled() : enable = true, columnName = null;

  Object? toJson() {
    if (!enable) return false;
    if (columnName != null) return columnName;
    return true;
  }
}

/// Options for optimistic locking version field.
/// If version is null, optimistic locking is disabled (false).
/// If version is a string, it uses that as the attribute name.
class VersionOption {
  /// The name of the version attribute. If null, version is disabled.
  final String? version;

  /// Create a VersionOption that disables version (false)
  const VersionOption.disabled() : version = null;

  /// Create a VersionOption with a custom version attribute name
  const VersionOption.custom(this.version);

  Object? toJson() {
    if (version == null) return false;
    return version;
  }
}

/// Marks a class as a database table
@Target({TargetKind.classType})
class Table {
  /// The name of the table in SQL.
  ///
  /// Default: The modelName, pluralized, unless freezeTableName is true,
  /// in which case it uses model name verbatim.
  ///
  /// Not inherited.
  final String? tableName;

  /// Don't persist null values. This means that all columns with null values will not be saved.
  ///
  /// Default: false
  final bool? omitNull;

  /// Sequelize will automatically add a primary key called `id` if no
  /// primary key has been added manually.
  ///
  /// Set to false to disable adding that primary key.
  ///
  /// Default: false
  final bool? noPrimaryKey;

  /// Adds createdAt and updatedAt timestamps to the model.
  ///
  /// Default: true
  final bool? timestamps;

  /// If true, calling destroy will not delete the model, but will instead set a `deletedAt` timestamp.
  ///
  /// This option requires timestamps to be true.
  /// The `deletedAt` column can be customized through deletedAt.
  ///
  /// Default: false
  final bool? paranoid;

  /// If true, Sequelize will snake_case the name of columns that do not have an explicit value set.
  /// The name of the table will also be snake_cased, unless tableName is set, or freezeTableName is true.
  ///
  /// Default: false
  final bool? underscored;

  /// Indicates if the model's table has a trigger associated with it.
  ///
  /// Default: false
  final bool? hasTrigger;

  /// If true, sequelize will use the name of the Model as-is as the name of the SQL table.
  /// If false, the name of the table will be pluralised (and snake_cased if underscored is true).
  ///
  /// This option has no effect if tableName is set.
  ///
  /// Default: false
  final bool? freezeTableName;

  /// An object with two attributes, `singular` and `plural`, which are used when this model is associated to others.
  ///
  /// Not inherited.
  final ModelNameOption? name;

  /// The name of the model.
  ///
  /// If not set, the name of the class will be used instead.
  /// You should specify this option if you are going to minify your code in a way that may mangle the class name.
  ///
  /// Not inherited.
  final String? modelName;

  /// Override the name of the createdAt attribute if a string is provided, or disable it if false.
  /// timestamps must be true.
  ///
  /// Not affected by underscored setting.
  final TimestampOption? createdAt;

  /// Override the name of the deletedAt attribute if a string is provided, or disable it if false.
  /// timestamps must be true.
  /// paranoid must be true.
  ///
  /// Not affected by underscored setting.
  final TimestampOption? deletedAt;

  /// Override the name of the updatedAt attribute if a string is provided, or disable it if false.
  /// timestamps must be true.
  ///
  /// Not affected by underscored setting.
  final TimestampOption? updatedAt;

  /// The database schema in which this table will be located.
  final String? schema;

  /// The delimiter used for schema names.
  final String? schemaDelimiter;

  /// The name of the database storage engine to use (e.g. MyISAM, InnoDB).
  ///
  /// MySQL, MariaDB only.
  final String? engine;

  /// The charset to use for the model
  final String? charset;

  /// A comment for the table.
  ///
  /// MySQL, PG only.
  final String? comment;

  /// The collation for model's table
  final String? collate;

  /// Set the initial AUTO_INCREMENT value for the table in MySQL.
  final String? initialAutoIncrement;

  /// Enable optimistic locking.
  /// When enabled, sequelize will add a version count attribute to the model and throw an
  /// OptimisticLockingError error when stale instances are saved.
  /// - If string: Uses the named attribute.
  /// - If boolean: Uses `version`.
  ///
  /// Default: false
  final VersionOption? version;

  const Table({
    this.tableName,
    this.omitNull,
    this.noPrimaryKey,
    this.timestamps = true,
    this.paranoid,
    this.underscored = false,
    this.hasTrigger,
    this.freezeTableName,
    this.name,
    this.modelName,
    this.createdAt,
    this.deletedAt,
    this.updatedAt,
    this.schema,
    this.schemaDelimiter,
    this.engine,
    this.charset,
    this.comment,
    this.collate,
    this.initialAutoIncrement,
    this.version,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (tableName != null) {
      json['tableName'] = tableName;
    }

    if (omitNull != null) {
      json['omitNull'] = omitNull;
    }
    if (noPrimaryKey != null) {
      json['noPrimaryKey'] = noPrimaryKey;
    }
    if (timestamps != null) {
      json['timestamps'] = timestamps;
    }
    if (paranoid != null) {
      json['paranoid'] = paranoid;
    } else if (deletedAt != null && deletedAt!.enable) {
      // Automatically enable paranoid mode when deletedAt is configured
      json['paranoid'] = true;
    }
    if (underscored != null) {
      json['underscored'] = underscored;
    }
    if (hasTrigger != null) {
      json['hasTrigger'] = hasTrigger;
    }
    if (freezeTableName != null) {
      json['freezeTableName'] = freezeTableName;
    }
    if (name != null) {
      json['name'] = name!.toJson();
    }
    if (modelName != null) {
      json['modelName'] = modelName;
    }
    if (createdAt != null) {
      json['createdAt'] = createdAt!.toJson();
    }
    if (deletedAt != null) {
      json['deletedAt'] = deletedAt!.toJson();
    }
    if (updatedAt != null) {
      json['updatedAt'] = updatedAt!.toJson();
    }
    if (schema != null) {
      json['schema'] = schema;
    }
    if (schemaDelimiter != null) {
      json['schemaDelimiter'] = schemaDelimiter;
    }
    if (engine != null) {
      json['engine'] = engine;
    }
    if (charset != null) {
      json['charset'] = charset;
    }
    if (comment != null) {
      json['comment'] = comment;
    }
    if (collate != null) {
      json['collate'] = collate;
    }
    if (initialAutoIncrement != null) {
      json['initialAutoIncrement'] = initialAutoIncrement;
    }
    if (version != null) {
      json['version'] = version!.toJson();
    }

    return json;
  }
}

@Target({TargetKind.field})
class PrimaryKey {
  const PrimaryKey();
}

@Target({TargetKind.field})
class NotNull {
  const NotNull();
}

@Target({TargetKind.field})
class AutoIncrement {
  const AutoIncrement();
}

@Target({TargetKind.field})
class AllowNull {
  const AllowNull();
}

@Target({TargetKind.field})
class ColumnName {
  final String name;
  const ColumnName(this.name);
}

enum DefaultType {
  uniqid,
  now,
  fn,
}

@Target({TargetKind.field})
class Default {
  final dynamic value;
  final DefaultType? type;
  final String? functionName;

  const Default(this.value) : type = null, functionName = null;
  const Default.uniqid()
    : value = null,
      type = DefaultType.uniqid,
      functionName = null;
  const Default.now()
    : value = null,
      type = DefaultType.now,
      functionName = null;
  const Default.fn(this.functionName) : value = null, type = DefaultType.fn;
}

@Target({TargetKind.field})
class Comment {
  final String comment;
  const Comment(this.comment);
}

@Target({TargetKind.field})
class Unique {
  final Object? value; // String? | dynamic (UniqueOption)
  const Unique([this.value]);
}

@Target({TargetKind.field})
class Index {
  final Object? value; // String? | dynamic (IndexOption)
  const Index([this.value]);
}
