import 'package:equatable/equatable.dart';

/// Base class for all failures in the app.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Returned when the device has no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection',
  ]);
}

/// Returned when the API responds with an error (4xx, 5xx)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(
      super.message, {
        this.statusCode,
      });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Returned when reading/writing to Hive local DB fails
class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Local cache error',
  ]);
}

/// Returned when a feature isn't available yet
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'An unexpected error occurred',
  ]);
}