/// Holds the response data from a Sequelize query along with instance metadata.
///
/// This class wraps the JSON data returned from queries with additional
/// Sequelize instance properties like `previous`, `changed`, and `isNewRecord`.
class ModelInstanceData {
  /// The model data as a JSON map
  final Map<String, dynamic> data;

  /// Previous values before any changes (from Sequelize _previousDataValues)
  final Map<String, dynamic> previous;

  /// List of changed field names, or empty list if no changes
  /// In JS, `changed()` returns `false` when no changes, we convert to empty list
  final List<String> changed;

  /// True if this instance has not been persisted to the database
  final bool isNewRecord;

  ModelInstanceData({
    required this.data,
    required this.previous,
    required this.changed,
    required this.isNewRecord,
  });

  /// Creates from the raw bridge response format
  /// Expected format: {data: {...}, previous: {...}, changed: [...] | false, isNewRecord: bool}
  factory ModelInstanceData.fromBridgeResponse(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final previous = response['previous'] as Map<String, dynamic>? ?? {};

    // Handle changed - can be List<String> or false
    final changedRaw = response['changed'];
    final changed = changedRaw is List
        ? changedRaw.map((e) => e.toString()).toList()
        : <String>[];

    final isNewRecord = response['isNewRecord'] as bool? ?? false;

    return ModelInstanceData(
      data: data,
      previous: previous,
      changed: changed,
      isNewRecord: isNewRecord,
    );
  }

  /// Returns true if there are any changes
  bool get hasChanges => changed.isNotEmpty;

  /// Returns true if a specific field was changed
  bool isFieldChanged(String fieldName) => changed.contains(fieldName);

  /// Gets the previous value for a specific field
  dynamic getPreviousValue(String fieldName) => previous[fieldName];
}
