import '../../model/fluent_me_model.dart';

abstract class FluentMeState {}

class FluentMeInitial extends FluentMeState {}

class FluentMeLoading extends FluentMeState {}

class FluentMeSuccess extends FluentMeState {
  final FluentMeResponse response;

  FluentMeSuccess(this.response);
}

class FluentMeError extends FluentMeState {
  final String message;

  FluentMeError(this.message);
}