/// Exception thrown by the bridge
class BridgeException implements Exception {
  final String message;
  final int? code;
  final String? stack;

  BridgeException(this.message, {this.code, this.stack});

  @override
  String toString() {
    final buffer = StringBuffer('BridgeException');
    if (message.isNotEmpty) {
      buffer.write(': $message');
    }
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    return buffer.toString();
  }
}
