part of 'authentication_bloc.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.pure,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
  });

  final FormzSubmissionStatus status;
  final Username username;
  final Password password;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Username? username,
    Password? password,
  }) =>
      LoginState(
        status: status ?? this.status,
        username: username ?? this.username,
        password: password ?? this.password,
      );

  @override
  List<Object> get props => [status, username, password];
}
