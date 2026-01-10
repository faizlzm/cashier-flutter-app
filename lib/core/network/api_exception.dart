/// Base class for all API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// 401 Unauthorized - token expired or invalid
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Sesi telah berakhir. Silakan login kembali.',
    super.statusCode = 401,
  });
}

/// 400 Bad Request - validation errors
class ValidationException extends ApiException {
  final List<ValidationError> errors;

  const ValidationException({
    super.message = 'Validasi gagal',
    super.statusCode = 400,
    this.errors = const [],
  });

  /// Get error message for a specific field
  String? getFieldError(String field) {
    final error = errors.where((e) => e.field == field).firstOrNull;
    return error?.message;
  }
}

/// Individual validation error
class ValidationError {
  final String field;
  final String message;

  const ValidationError({required this.field, required this.message});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

/// 403 Forbidden - no permission
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Anda tidak memiliki akses ke resource ini.',
    super.statusCode = 403,
  });
}

/// 404 Not Found
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Data tidak ditemukan.',
    super.statusCode = 404,
  });
}

/// 500+ Server errors
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Terjadi kesalahan pada server. Silakan coba lagi.',
    super.statusCode = 500,
  });
}

/// Network error - no internet connection
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Tidak ada koneksi internet.',
    super.statusCode,
  });
}

/// Timeout error
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Koneksi timeout. Silakan coba lagi.',
    super.statusCode,
  });
}
