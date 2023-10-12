import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/packages/rebranding/rebranding_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

// TODO: Remove the code after the rebranding notice has expired. See date
// specified in [appConfig.isRebrandingExpired?].
class RebrandingDialog extends StatefulWidget {
  final bool isModal;

  const RebrandingDialog({this.isModal = true});

  @override
  _RebrandingDialogState createState() => _RebrandingDialogState();
}

class _RebrandingDialogState extends State<RebrandingDialog> {
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    if (widget.isModal) {
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _canClose = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _canClose;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Color(0xFFDADFE4),
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: widget.isModal ? 36 : 24,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: SvgPicture.asset(
                          'assets/rebranding/old_logo.svg',
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/rebranding/arrow.svg',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Flexible(
                        child: SvgPicture.asset(
                          'assets/rebranding/new_logo.svg',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    AppLocalizations.of(context).rebrandingAnnouncement,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 24.0),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                      onPressed: () async {
                        const url =
                            'https://komodoplatform.com/en/blog/brand-unification';
                        await canLaunchUrlString(url)
                            ? await launchUrlString(url)
                            : throw Exception(
                                'Could not launch "Official press release" URL',
                              );
                        if (widget.isModal) {
                          Provider.of<RebrandingProvider>(
                            context,
                            listen: false,
                          ).closePermanently();
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context).officialPressRelease,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isModal && _canClose)
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onPressed: _canClose
                        ? () {
                            Provider.of<RebrandingProvider>(
                              context,
                              listen: false,
                            ).closePermanently();
                            Navigator.of(context).pop();
                          }
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
