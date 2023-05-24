import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/packages/wallets/bloc/wallets_bloc.dart';
import 'package:komodo_dex/packages/wallets/events/wallets_quick_create_submitted.dart';

@immutable
// TODO: Migrate logic and state in this widget into a new bloc
// (e.g. QuickCreateWalletBloc) or expand an existing bloc.
class QuickCreateWalletButton extends StatefulWidget {
  const QuickCreateWalletButton({Key? key}) : super(key: key);

  @override
  State<QuickCreateWalletButton> createState() =>
      _QuickCreateWalletButtonState();
}

class _QuickCreateWalletButtonState extends State<QuickCreateWalletButton> {
  final _nameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  'Quick Setup a New Wallet?'), // TODO: Localize this string with AppLocalizations.of(context)
              // Example: Text(AppLocalizations.of(context)!.createNewWallet)
              content: Text(
                  'A new wallet will be created with a generated seed phrase. '
                  'This seed phrase will be securely stored on your device. \n\n'
                  'WARNING: If you change your device\'s biometric security '
                  'settings, the seed phrase will be cleared and you will need'
                  ' to enter the seed to restore your wallet.' // TODO: Localize this string
                  // Example: Text(AppLocalizations.of(context)!.walletCreationWarning)
                  ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'), // TODO: Localize this string
                  // Example: Text(AppLocalizations.of(context)!.cancel)
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Proceed'), // TODO: Localize this string
                  // Example: Text(AppLocalizations.of(context)!.proceed)
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showFormDialog(context);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Icon(Icons.add),
    );
  }

  void _showFormDialog(BuildContext context) {
    _nameController.clear();
    _descriptionController.clear();
    _isLoading = false;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Wallet Details'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Wallet Name',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Wallet Description',
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'), // TODO: Localize this string
                // Example: Text(AppLocalizations.of(context)!.cancel)
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
              ),
              TextButton(
                child: Text('Create'), // TODO: Localize this string
                // Example: Text(AppLocalizations.of(context)!.create)
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          context.read<WalletsBloc>().add(
                                WalletsQuickCreateSubmitted(
                                  name: _nameController.text,
                                  description: _descriptionController.text,
                                ),
                              );
                          Navigator.of(context).pop();
                        }
                      },
              ),
            ],
          );
        });
      },
    );
  }
}
