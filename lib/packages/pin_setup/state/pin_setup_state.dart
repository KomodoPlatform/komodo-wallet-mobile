// import 'package:formz/formz.dart';
// import 'package:komodo_dex/login/models/pin.dart';
// import 'package:komodo_dex/login/models/pin_type.dart';

// abstract class PinSetupState with FormzMixin {
//   const PinSetupState({
//     required this.submissionStatus,
//     required this.pin,
//     required this.confirmPin,
//     required this.pinType,
//     this.errorMessage,
//   });

//   final FormzSubmissionStatus submissionStatus;
//   final Pin pin;
//   final Pin confirmPin;
//   final String? errorMessage;
//   final PinTypeName pinType;

//   bool get isLoading => submissionStatus.isInProgress;
//   bool get isError => submissionStatus.isFailure;
//   bool get isSuccess => submissionStatus.isSuccess;

//   @override
//   List<FormzInput> get inputs => [pin, confirmPin];

//   PinSetupState fromJson(Map<String, dynamic> json);
//   Map<String, dynamic> toJson();
// }

// class PinSetupInitial extends PinSetupState {
//   const PinSetupInitial()
//       : super(
//           submissionStatus: FormzSubmissionStatus.initial,
//           pin: const Pin.pure(),
//           confirmPin: const Pin.pure(),
//           pinType: PinTypeName.regular,
//         );

//   @override
//   PinSetupInitial fromJson(Map<String, dynamic> json) {
//     throw UnimplementedError();
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     throw UnimplementedError();
//   }
// }

// class PinSetupLoading extends PinSetupState {
//   const PinSetupLoading({
//     required Pin pin,
//     required Pin confirmPin,
//     required PinTypeName pinType,
//   }) : super(
//           submissionStatus: FormzSubmissionStatus.inProgress,
//           pin: pin,
//           confirmPin: confirmPin,
//           pinType: pinType,
//         );

//   @override
//   PinSetupLoading fromJson(Map<String, dynamic> json) {
//     return PinSetupLoading(
//       pin: Pin.fromJson(json['pin'] as Map<String, dynamic>),
//       confirmPin: Pin.fromJson(json['confirmPin'] as Map<String, dynamic>),
//       pinType: PinTypeName.values.firstWhere(
//         (e) => e.toString() == json['pinType'] as String,
//       ),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'pin': pin.toJson(),
//       'confirmPin': confirmPin.toJson(),
//       'pinType': pinType.toString(),
//     };
//   }
// }

// class PinSetupSuccess extends PinSetupState {
//   const PinSetupSuccess({
//     required Pin pin,
//     required Pin confirmPin,
//     required PinTypeName pinType,
//   }) : super(
//           submissionStatus: FormzSubmissionStatus.success,
//           pin: pin,
//           confirmPin: confirmPin,
//           pinType: pinType,
//         );

//   @override
//   PinSetupSuccess fromJson(Map<String, dynamic> json) {
//     return PinSetupSuccess(
//       pin: Pin.fromJson(json['pin'] as Map<String, dynamic>),
//       confirmPin: Pin.fromJson(json['confirmPin'] as Map<String, dynamic>),
//       pinType: PinTypeName.values.firstWhere(
//         (e) => e.toString() == json['pinType'] as String,
//       ),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'pin': pin.toJson(),
//       'confirmPin': confirmPin.toJson(),
//       'pinType': pinType.toString(),
//     };
//   }
// }

// class PinSetupFailure extends PinSetupState {
//   const PinSetupFailure({
//     required Pin pin,
//     required Pin confirmPin,
//     required PinTypeName pinType,
//     required String errorMessage,
//   }) : super(
//           submissionStatus: FormzSubmissionStatus.failure,
//           pin: pin,
//           confirmPin: confirmPin,
//           // pinType: pinType,
//           errorMessage: errorMessage,
//         );

//   @override
//   PinSetupFailure fromJson(Map<String, dynamic> json) {
//     return PinSetupFailure(
//       pin: Pin.fromJson(json['pin'] as Map<String, dynamic>),
//       confirmPin: Pin.fromJson(json['confirmPin'] as Map<String, dynamic>),
//       pinType: PinTypeName.values.firstWhere(
//         (e) => e.toString() == json['pinType'] as String,
//       ),
//       errorMessage: json['errorMessage'] as String,
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'pin': pin.toJson(),
//       'confirmPin': confirmPin.toJson(),
//       'pinType': pinType.toString(),
//       'errorMessage': errorMessage,
//     };
//   }
// }
