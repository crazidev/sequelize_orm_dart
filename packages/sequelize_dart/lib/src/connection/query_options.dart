class QueryOptions {
  ///Pass query execution time in milliseconds as second argument to logging function.
  final bool? benchmark;

  /// A function that gets executed while running the query to log the sql.
  final (String sql, int? timing)? logging;

  /// If true, transforms objects with . separated property names into nested objects using dottie.js.
  /// For example { 'user.username': 'john' } becomes { user: { username: 'john' }}.
  /// When nest is true, the query type is assumed to be 'SELECT', unless otherwise specified
  final bool? nest;

  QueryOptions({this.benchmark, this.logging, this.nest});
}

