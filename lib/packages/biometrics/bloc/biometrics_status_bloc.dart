import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/packages/biometrics/event/biometrics_status_event.dart';
import 'package:komodo_dex/packages/biometrics/repository/biometrics_status_repository.dart';
import 'package:komodo_dex/packages/biometrics/state/biometrics_status_state.dart';

// BiometricsStatusBloc
class BiometricsStatusBloc
    extends HydratedBloc<BiometricsStatusEvent, BiometricsStatusState> {
  final BiometricsStatusRepository _biometricsStatusRepository;

  BiometricsStatusBloc(this._biometricsStatusRepository)
      : super(BiometricsStatusInitial()) {
    on<BiometricsStatusSubscriptionRequested>(_handleStartSubscription);
  }

  Future<void> _handleStartSubscription(
      BiometricsStatusSubscriptionRequested event,
      Emitter<BiometricsStatusState> emit) async {
    emit(BiometricsStatusInitial());
    await emit.forEach(_biometricsStatusRepository.biometricsAvailableStream(),
        onData: (status) {
      if (status == BiometricsStatus.available) {
        return BiometricsStatusAvailable();
      } else if (status == BiometricsStatus.notEnrolled) {
        return BiometricsNotEnrolled(message: 'Biometrics is not enrolled.');
      } else if (status == BiometricsStatus.notAuthenticated) {
        return BiometricsStatusNotAuthenticated(
            message: 'Biometrics is not authenticated.');
      } else {
        return BiometricsStatusNotSupported(
            message: 'Biometrics is not supported.');
      }
    });
  }

  @override
  BiometricsStatusState? fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    if (status == null) {
      return null;
    } else if (status == 'available') {
      return BiometricsStatusAvailable();
    } else if (status == 'notEnrolled') {
      return BiometricsNotEnrolled(message: 'Biometrics is not enrolled.');
    } else if (status == 'notAuthenticated') {
      return BiometricsStatusNotAuthenticated(
          message: 'Biometrics is not authenticated.');
    } else {
      return BiometricsStatusNotSupported(
          message: 'Biometrics is not supported.');
    }
  }

  @override
  Map<String, dynamic>? toJson(BiometricsStatusState state) {
    if (state is BiometricsStatusAvailable) {
      return {'status': 'available'};
    } else if (state is BiometricsNotEnrolled) {
      return {'status': 'notEnrolled'};
    } else if (state is BiometricsStatusNotAuthenticated) {
      return {'status': 'notAuthenticated'};
    } else if (state is BiometricsStatusNotSupported) {
      return {'status': 'notSupported'};
    } else {
      return null;
    }
  }
}
