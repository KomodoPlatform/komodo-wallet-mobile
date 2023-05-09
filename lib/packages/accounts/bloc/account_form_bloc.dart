import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:komodo_dex/packages/accounts/events/account_form_event.dart';
import 'package:komodo_dex/packages/accounts/models/account_description.dart';
import 'package:komodo_dex/packages/accounts/models/account_name.dart';
import 'package:komodo_dex/packages/accounts/repository/account_repository.dart';
import 'package:komodo_dex/packages/accounts/state/account_form_state.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';

class AccountFormBloc extends Bloc<AccountFormEvent, AccountFormState> {
  AccountFormBloc(
      {required AccountRepository accountRepository,
      required AuthenticationRepository authenticationRepository})
      : _accountRepository = accountRepository,
        _authenticationRepository = authenticationRepository,
        super(const AccountFormState.initial()) {
    on<AccountFormStartedEvent>(_onAccountFormStartedEvent);
    on<AccountFormNameChanged>(_onAccountFormNameChanged);
    on<AccountFormDescriptionChanged>(_onAccountFormDescriptionChanged);
    on<AccountFormSubmitted>(_onAccountFormSubmitted);
  }

  final AccountRepository _accountRepository;
  final AuthenticationRepository _authenticationRepository;

  void _onAccountFormStartedEvent(
      AccountFormStartedEvent event, Emitter<AccountFormState> emit) {
    final accountId = event.accountId;

    final name = event.name == null
        ? AccountName.pure()
        : AccountName.dirty(event.name!);

    final description = event.description == null
        ? AccountDescription.pure()
        : AccountDescription.dirty(event.description!);

    emit(
      AccountFormState(
        accountId: accountId,
        themeColor: event.themeColor,
        avatar: event.avatar,
        name: name,
        description: description,
        submissionStatus: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onAccountFormNameChanged(
      AccountFormNameChanged event, Emitter<AccountFormState> emit) {
    final name = AccountName.dirty(event.name);
    emit(state.copyWith(name: name));
  }

  void _onAccountFormDescriptionChanged(
      AccountFormDescriptionChanged event, Emitter<AccountFormState> emit) {
    final description = AccountDescription.dirty(event.description);
    emit(state.copyWith(description: description));
  }

  void _onAccountFormSubmitted(
      AccountFormSubmitted event, Emitter<AccountFormState> emit) async {
    if (state.isValid) {
      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));
      try {
        await _accountRepository.createAccount(
          name: state.name.value,
          description: state.description.value,
          avatar: state.avatar,
          themeColor: state.themeColor,
        );

        emit(state.copyWith(submissionStatus: FormzSubmissionStatus.success));
      } catch (e) {
        emit(state.copyWith(submissionStatus: FormzSubmissionStatus.failure));
      }
    } else {
      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.failure));
    }
  }
}
