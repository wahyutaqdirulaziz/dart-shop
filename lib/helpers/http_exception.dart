class HttpException implements Exception {
  final String _message;

  HttpException(this._message);

  @override
  String toString() {
    return _message;
  }

  bool hasError(String error) {
    return _message.contains(error);
  }
}
