class HttpException implements Exception {
  final String _message;

  const HttpException(this._message);

  @override
  String toString() {
    return _message;
  }
}
