/// Base Query class - platform independent
/// Both JS and Dart Query implementations should be compatible with this interface
abstract class QueryInterface {
  /// Convert query to JSON format
  Map<String, dynamic> toJson();
}

