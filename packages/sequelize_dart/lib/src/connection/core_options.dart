enum SequelizeDialects {
  postgres('postgres'),
  mysql('mysql'),
  mariadb('mariadb'),
  sqlite('sqlite'),
  mssql('mssql'),
  db2('db2');

  final String value;
  const SequelizeDialects(this.value);
}

class SequelizePoolOptions {
  /// Maximum number of connections in pool
  final int? max;

  /// Minimum number of connections in pool
  final int? min;

  /// The maximum time, in milliseconds, that a connection can be idle before being released
  final int? idle;

  /// The maximum time, in milliseconds, that pool will try to get connection before throwing error
  final int? acquire;

  /// The time interval, in milliseconds, for evicting idle connections
  final int? evict;

  SequelizePoolOptions({
    this.max,
    this.min,
    this.idle,
    this.acquire,
    this.evict,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (max != null) map['max'] = max;
    if (min != null) map['min'] = min;
    if (idle != null) map['idle'] = idle;
    if (acquire != null) map['acquire'] = acquire;
    if (evict != null) map['evict'] = evict;
    return map;
  }
}

class SequelizeCoreOptions {
  /// The connection URL. If other connection options are set, they will override the values set in this URL.
  final String? url;

  /// If defined, the connection will use the provided schema instead of the default ("public")
  final String? database;
  final String? host;
  final String? user;
  final String? password;
  final int? port;

  /// Whether to hoist order and group from joined includes to the top level.
  /// Normally Sequelize ignores 'order' and 'group' inside joined includes.
  /// Default is false.
  final bool hoistIncludeOptions;

  SequelizeCoreOptions({
    this.database,
    this.url,
    this.host,
    this.user,
    this.password,
    this.port,
    this.hoistIncludeOptions = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'username': user,
      'password': password,
      'port': port,
      'database': database,
      'url': url,
      'hoistIncludeOptions': hoistIncludeOptions,
    };
  }
}
