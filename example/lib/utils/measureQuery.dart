/// Helper function to measure query execution time
/// Usage: await measureQuery('Query name', () => yourQuery);
Future<T> measureQuery<T>(
  String queryName,
  Future<T> Function() query,
) async {
  final startTime = DateTime.now();
  final result = await query();
  final duration = DateTime.now().difference(startTime);
  print('[$queryName] completed in ${duration.inMilliseconds}ms');
  return result;
}
