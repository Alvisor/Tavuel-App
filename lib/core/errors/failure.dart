import 'package:flutter/foundation.dart';

/// Represents a failure in the application, used as the Left side
/// of an Either pattern for functional error handling.
///
/// Usage with a simple Result type:
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await api.fetchUser(id);
///     return Result.success(user);
///   } on AppException catch (e) {
///     return Result.failure(Failure.fromException(e));
///   }
/// }
/// ```
@immutable
class Failure {
  final String message;
  final int? statusCode;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.statusCode,
    this.stackTrace,
  });

  /// Create a Failure from any exception.
  factory Failure.fromException(Exception exception, [StackTrace? stackTrace]) {
    return Failure(
      message: exception.toString(),
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.message == message &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode;
}

// ──────────────────────────────────────────────
// Typed failure subclasses
// ──────────────────────────────────────────────

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Error del servidor.',
    super.statusCode = 500,
    super.stackTrace,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Error de conexión.',
    super.stackTrace,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Error de autenticación.',
    super.statusCode = 401,
    super.stackTrace,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error de almacenamiento local.',
    super.stackTrace,
  });
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Error de validación.',
    this.fieldErrors,
    super.statusCode = 422,
    super.stackTrace,
  });
}

// ──────────────────────────────────────────────
// Simple Result type (Either alternative)
// ──────────────────────────────────────────────

/// A lightweight Result type that holds either a [Failure] or a success value.
@immutable
class Result<T> {
  final T? _data;
  final Failure? _failure;

  const Result._({T? data, Failure? failure})
      : _data = data,
        _failure = failure;

  /// Creates a successful result.
  factory Result.success(T data) => Result._(data: data);

  /// Creates a failed result.
  factory Result.failure(Failure failure) => Result._(failure: failure);

  /// Whether this result is a success.
  bool get isSuccess => _failure == null;

  /// Whether this result is a failure.
  bool get isFailure => _failure != null;

  /// Returns the success data. Throws if this is a failure.
  T get data {
    if (_failure != null) {
      throw StateError('Cannot access data on a failed Result: $_failure');
    }
    return _data as T;
  }

  /// Returns the failure. Throws if this is a success.
  Failure get failure {
    if (_failure == null) {
      throw StateError('Cannot access failure on a successful Result.');
    }
    return _failure;
  }

  /// Pattern-match on the result.
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (_failure != null) {
      return failure(_failure);
    }
    return success(_data as T);
  }

  /// Map the success value.
  Result<R> map<R>(R Function(T data) transform) {
    if (_failure != null) {
      return Result.failure(_failure);
    }
    return Result.success(transform(_data as T));
  }

  /// FlatMap (bind) the success value.
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    if (_failure != null) {
      return Result.failure(_failure);
    }
    return transform(_data as T);
  }
}
