part of 'freezed.super.dart';

mixin _$Union {
  TResult map<TResult>(
          {required TResult Function(Data value) data,
          required TResult Function(Loading value) loading,
          required TResult Function(ErrorDetails value) error}) =>
      throw UnimplementedError();
}

class Data implements Union {
  const Data(this.value);

  final int value;

  TResult map<TResult>(
          {required TResult Function(Data value) data,
          required TResult Function(Loading value) loading,
          required TResult Function(ErrorDetails value) error}) =>
      data(this);
}

class Loading implements Union {
  const Loading();

  TResult map<TResult>(
          {required TResult Function(Data value) data,
          required TResult Function(Loading value) loading,
          required TResult Function(ErrorDetails value) error}) =>
      loading(this);
}

class ErrorDetails implements Union {
  const ErrorDetails([this.message]);

  final String? message;

  TResult map<TResult>(
          {required TResult Function(Data value) data,
          required TResult Function(Loading value) loading,
          required TResult Function(ErrorDetails value) error}) =>
      error(this);
}
