import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends HydratedBloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginEvent>((event, emit) {
      // TODO: implement event handler
    });
  }

  @override
  Map<String, dynamic> toJson(LoginState state) {
    // TODO: implement toJson
  }

  @override
  LoginState fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
  }
}
