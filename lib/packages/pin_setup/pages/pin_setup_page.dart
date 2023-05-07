// import 'package:flutter/material.dart';

// class PinSetupPage extends StatelessWidget {
//   const PinSetupPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Set Up PIN')),
//       body: BlocProvider<PinSetupBloc>(
//         create: (context) => PinSetupBloc(
//           loginRepository: RepositoryProvider.of<LoginRepository>(context),
//         ),
//         child: PinSetupForm(),
//       ),
//     );
//   }
// }

// class PinSetupForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PinSetupBloc, PinSetupState>(
//       builder: (context, state) {
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'PIN'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {
//                   context.read<PinSetupBloc>().add(PinSetupInputChanged(value));
//                 },
//               ),
//               const SizedBox(height: 16.0),
//               state.submissionStatus.isSubmissionInProgress
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: state.pin.valid
//                           ? () {
//                               context
//                                   .read<PinSetupBloc>()
//                                   .add(const PinSetupSubmitted());
//                             }
//                           : null,
//                       child: const Text('Submit'),
//                     ),
//               if (state.submissionStatus.isSubmissionFailure)
//                 const Text(
//                   'Failed to set up PIN',
//                   style: TextStyle(color: Colors.red),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
