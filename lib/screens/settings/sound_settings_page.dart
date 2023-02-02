import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../generic_blocs/dialog_bloc.dart';
import '../../localizations.dart';
import '../authentification/lock_screen.dart';
import '../../services/lock_service.dart';
import '../../services/music_service.dart';
import '../../utils/log.dart';
import '../../widgets/custom_simple_dialog.dart';
import '../../widgets/sound_volume_button.dart';

class SoundSettingsPage extends StatefulWidget {
  @override
  _SoundSettingsPageState createState() => _SoundSettingsPageState();
}

class _SoundSettingsPageState extends State<SoundSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              AppLocalizations.of(context).soundSettingsTitle.toUpperCase()),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
              child: Text(AppLocalizations.of(context).soundsExplanation,
                  style: TextStyle(
                    height: 1.3,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withOpacity(0.7),
                  )),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).soundOption),
              trailing:
                  const SoundVolumeButton(key: Key('settings-sound-button')),
              tileColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 1,
            ),
            SoundPicker(
                MusicMode.TAKER,
                AppLocalizations.of(context).soundTaker,
                AppLocalizations.of(context).soundTakerDesc),
            const SizedBox(
              height: 1,
            ),
            SoundPicker(
                MusicMode.MAKER,
                AppLocalizations.of(context).soundMaker,
                AppLocalizations.of(context).soundMakerDesc),
            const SizedBox(
              height: 1,
            ),
            SoundPicker(
                MusicMode.ACTIVE,
                AppLocalizations.of(context).soundActive,
                AppLocalizations.of(context).soundActiveDesc),
            const SizedBox(
              height: 1,
            ),
            SoundPicker(
                MusicMode.FAILED,
                AppLocalizations.of(context).soundFailed,
                AppLocalizations.of(context).soundFailedDesc),
            const SizedBox(
              height: 1,
            ),
            SoundPicker(
                MusicMode.APPLAUSE,
                AppLocalizations.of(context).soundApplause,
                AppLocalizations.of(context).soundApplauseDesc),
          ],
        ),
      ),
    );
  }
}

/// See if the file is an auudio file we can play.
bool checkAudioFile(String path) {
  if (path == null) return false;
  return path.endsWith('.mp3') || path.endsWith('.wav');
}

class FilePickerButton extends StatelessWidget {
  const FilePickerButton(this.musicMode, this.description);
  final MusicMode musicMode;
  final String description;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        key: const Key('file-picker-button'), //
        splashRadius: 24,
        icon: Icon(Icons.folder_open),
        color: Theme.of(context).toggleableActiveColor,
        onPressed: () async {
          FilePickerResult filePickerResult;
          final int lockCookie = lockService.enteringFilePicker();
          try {
            filePickerResult = await FilePicker.platform.pickFiles();
          } catch (err) {
            Log('setting_page:804', 'file picker exception: $err');
          }
          lockService.filePickerReturned(lockCookie);

          if (filePickerResult == null) return;

          PlatformFile pFile;
          if (filePickerResult.count != 0) {
            pFile = filePickerResult.files[0];
            if (pFile == null) {
              return;
            }
          }

          // On iOS this happens *after* pin lock, but very close in time to it (same second),
          // on Android/debug *before* pin lock,
          // chance is it's unordered.
          Log('setting_page:811', 'file picked: ${pFile.path}');

          final bool ck = checkAudioFile(pFile.path);
          if (!ck) {
            dialogBloc.dialog = showDialog<dynamic>(
              context: context,
              builder: (context) => CustomSimpleDialog(
                title: Text(AppLocalizations.of(context).soundCantPlayThat),
                children: <Widget>[
                  Text(AppLocalizations.of(context)
                      .soundCantPlayThatMsg(description)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.of(context).warningOkBtn),
                      ),
                    ],
                  ),
                ],
              ),
            ).then((dynamic _) => dialogBloc.dialog = null);
            return;
          }
          await musicService.setSoundPath(musicMode, pFile.path);
        });
  }
}

class SoundPicker extends StatelessWidget {
  const SoundPicker(this.musicMode, this.name, this.description);
  final MusicMode musicMode;
  final String name, description;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: AppLocalizations.of(context).soundPlayedWhen(description),
        child: ListTile(
          title: Text(name, style: Theme.of(context).textTheme.bodyText2),
          trailing: FilePickerButton(musicMode, description),
          tileColor: Theme.of(context).primaryColor,
        ));
  }
}
