/// Base exception class for all Tavuel application errors.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppException({
    this.message = 'Ocurrio un error inesperado.',
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() =>
      'AppException(message: $message, statusCode: $statusCode)';
}

/// Thrown when a network-related error occurs (timeout, no connection, etc.).
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Error de conexion. Verifica tu internet.',
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() =>
      'NetworkException(message: $message, statusCode: $statusCode)';
}

/// Thrown when the user is not authenticated or the token is invalid/expired.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Tu sesion ha expirado. Inicia sesion nuevamente.',
    super.originalError,
  }) : super(statusCode: 401);

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}

/// Thrown when the server returns a 5xx status code.
class ServerException extends AppException {
  const ServerException({
    super.message = 'Error del servidor. Intenta mas tarde.',
    super.statusCode = 500,
    super.originalError,
  });

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode)';
}

/// Thrown when data validation fails on the client side.
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    super.message = 'Los datos ingresados no son validos.',
    this.fieldErrors,
    super.originalError,
  }) : super(statusCode: 422);

  @override
  String toString() =>
      'ValidationException(message: $message, fields: $fieldErrors)';
}

/// Thrown when a requested resource is not found.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Recurso no encontrado.',
    super.originalError,
  }) : super(statusCode: 404);

  @override
  String toString() => 'NotFoundException(message: $message)';
}

/// Thrown when the user does not have permission for an action.
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'No tienes permisos para realizar esta accion.',
    super.originalError,
  }) : super(statusCode: 403);

  @override
  String toString() => 'ForbiddenException(message: $message)';
}

/// Thrown when local cache or storage operations fail.
class CacheException extends AppException {
  const CacheException({
    super.message = 'Error al acceder a los datos almacenados.',
    super.originalError,
  });

  @override
  String toString() => 'CacheException(message: $message)';
}
