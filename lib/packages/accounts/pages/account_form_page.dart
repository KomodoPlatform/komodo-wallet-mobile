import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/packages/accounts/bloc/account_form_bloc.dart';
import 'package:komodo_dex/packages/accounts/events/account_form_event.dart';
import 'package:komodo_dex/packages/accounts/state/account_form_state.dart';
import 'package:komodo_dex/utils/iterable_utils.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class AccountFormPage extends StatefulWidget {
  final AccountId? accountId;

  const AccountFormPage({Key? key, this.accountId}) : super(key: key);

  @override
  _AccountFormPageState createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  // TODO: Implement in bloc to handle image and color state. Currently in UI
  // as a PoC.
  final _picker = ImagePicker();
  XFile? _imageFile;
  Image? _image;
  Color? _selectedColor;

  // @override
  // void initState() {
  //   super.initState();
  //   context.read<AccountFormBloc>().add(AccountFormStartedEvent (accountId: widget.accountId));
  // }

  List<Color> get _colors => [
        ...Colors.primaries,
        context.read<AccountFormBloc>().state.themeColor,
      ].whereNotNull().toSet().toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.accountId == null ? 'Create Account' : 'Edit Account'),
      ),
      body: BlocConsumer<AccountFormBloc, AccountFormState>(
        listener: _listenFormResult,
        listenWhen: _listenWhenSubmissionStatusChanged,
        builder: (context, state) {
          final isLoading = state.submissionStatus.isInProgress;
          final isReadOnly = isLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: isReadOnly
                      ? null
                      : () async {
                          _image = null;
                          _imageFile = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (_imageFile != null) {
                            _image = Image.memory(
                              await _imageFile!.readAsBytes(),
                              key: ValueKey(_imageFile!.path),
                            );
                            context.read<AccountFormBloc>().add(
                                  AccountFormAvatarChanged(
                                      await _imageFile!.readAsBytes()),
                                );
                          }
                          setState(() {});
                        },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    foregroundImage: _image != null ? _image!.image : null,
                    child: _image == null
                        ? Icon(Icons.add_a_photo,
                            size: 40, color: Colors.grey[800])
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Tap to add/change photo',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.caption?.color),
                ),
                SizedBox(height: 16),
                TextFormField(
                  readOnly: isReadOnly,
                  onChanged: (value) {
                    context.read<AccountFormBloc>().add(
                          AccountFormNameChanged(value),
                        );
                  },
                  initialValue: state.name.value,
                  decoration: InputDecoration(
                    labelText: 'Account Name',
                    border: OutlineInputBorder(),
                    errorText: state.name.displayError?.toString(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  readOnly: isReadOnly,
                  onChanged: (value) {
                    context
                        .read<AccountFormBloc>()
                        .add(AccountFormDescriptionChanged(value));
                  },
                  initialValue: state.description.value,
                  decoration: InputDecoration(
                    labelText: 'Account Description',
                    border: OutlineInputBorder(),
                    errorText: state.description.isNotValid
                        ? 'Invalid account description'
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                Text('Theme Color'),
                DropdownButton<Color>(
                  value: state.themeColor,
                  onChanged: isReadOnly
                      ? null
                      : (Color? newValue) {
                          context.read<AccountFormBloc>().add(
                                AccountFormThemeColorChanged(newValue!),
                              );
                          setState(() {
                            _selectedColor = newValue;
                          });
                        },
                  items: _colors.map((Color color) {
                    // TODO: Replace with a color picker
                    return DropdownMenuItem<Color>(
                      value: color,
                      child: Container(
                        width: 50,
                        height: 50,
                        color: color,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                PrimaryButton(
                  onPressed: (isReadOnly || state.isNotValid)
                      ? null
                      : () {
                          context
                              .read<AccountFormBloc>()
                              .add(AccountFormSubmitted());
                        },
                  text: 'Submit',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _listenWhenSubmissionStatusChanged(
      AccountFormState previous, AccountFormState current) {
    final didStatusChange =
        current.submissionStatus != previous.submissionStatus;

    final didSucceed = current.submissionStatus.isSuccess;

    final didErrorChange = current.error != previous.error;

    return didStatusChange || didSucceed || didErrorChange;
  }

  void _listenFormResult(BuildContext context, AccountFormState state) {
    final status = state.submissionStatus;
    if (status.isSuccess) {
      Navigator.of(context).pop();
    } else if (status.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error ?? AppLocalizations().errorTryAgain),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
