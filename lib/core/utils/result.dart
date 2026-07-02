import 'package:equatable/equatable.dart';

/// A standard result type for handling success and failure in the data layer.
sealed class Result<T> extends Equatable {
  const Result();

  @override
  List<Object?> get props => [];
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

final class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;

  const Failure(this.message, [this.exception]);

  @override
  List<Object?> get props => [message, exception];
}
