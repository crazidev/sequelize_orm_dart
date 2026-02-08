/// Holds the response data from a Sequelize query along with instance metadata.
class ModelInstanceData {
  /// The model data as a JSON map
  final Map<String, dynamic> data;

  // TODO: Enable isNewRecord, changed & previous
  // final Map<String, dynamic> previous;
  // final List<String> changed;
  // final bool isNewRecord;

  ModelInstanceData({
    required this.data,
    // required this.previous,
    // required this.changed,
    // required this.isNewRecord,
  });

  /// Creates from the raw bridge response format
  /// TODO: Enable isNewRecord, changed & previous
  factory ModelInstanceData.fromBridgeResponse(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>? ?? {};
    // final previous = response['previous'] as Map<String, dynamic>? ?? {};
    // final changedRaw = response['changed'];
    // final changed = changedRaw is List
    //     ? changedRaw.map((e) => e.toString()).toList()
    //     : <String>[];
    // final isNewRecord = response['isNewRecord'] as bool? ?? false;

    return ModelInstanceData(
      data: data,
      // previous: previous,
      // changed: changed,
      // isNewRecord: isNewRecord,
    );
  }

  // TODO: Enable isNewRecord, changed & previous
  // bool get hasChanges => changed.isNotEmpty;
  // bool isFieldChanged(String fieldName) => changed.contains(fieldName);
  // dynamic getPreviousValue(String fieldName) => previous[fieldName];
}
