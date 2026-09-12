class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

class ApiException extends AppException {
  const ApiException(
    super.message, {
    super.statusCode,
    super.details,
  });
}
