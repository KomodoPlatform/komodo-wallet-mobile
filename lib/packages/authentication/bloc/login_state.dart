import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:komodo_dex/packages/authentication/login/models.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
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
