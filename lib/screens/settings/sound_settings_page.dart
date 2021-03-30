import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/settings/setting_page.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/services/music_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/sound_volume_button.dart';

class SoundSettingsPage extends StatefulWidget {
  @override
  _SoundSettingsPageState createState() => _SoundSettingsPageState();
}

class _SoundSettingsPageState extends State<SoundSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).soundSettingsTitle.toUpperCase(),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
              child: Text(AppLocalizations.of(context).soundsExplanation,
                  style: TextStyle(
                    height: 1.3,
                    color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.7),
                  )),
            ),
            CustomTile(
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context).soundOption,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).textTheme.bodyText2.color),
                ),
                trailing:
                    const SoundVolumeButton(key: Key('settings-sound-button')),
              ),
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
        key: const Key('file-picker-button'),
        icon: Icon(Icons.folder_open),
        color: Theme.of(context).toggleableActiveColor,
        onPressed: () async {
          String path;
          final int lockCookie = lockService.enteringFilePicker();
          try {
            path = await FilePicker.getFilePath();
          } catch (err) {
            Log('setting_page:804', 'file picker exception: $err');
          }
          lockService.filePickerReturned(lockCookie);

          // On iOS this happens *after* pin lock, but very close in time to it (same second),
          // on Android/debug *before* pin lock,
          // chance is it's unordered.
          Log('setting_page:811', 'file picked: $path');

          final bool ck = checkAudioFile(path);
          if (!ck) {
            showDialog<dynamic>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context).soundCantPlayThat),
                content: Text(AppLocalizations.of(context)
                    .soundCantPlayThatMsg(description)),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
            return;
          }
          await musicService.setSoundPath(musicMode, path);
        });
  }
}

class SoundPicker extends StatelessWidget {
  const SoundPicker(this.musicMode, this.name, this.description);
  final MusicMode musicMode;
  final String name, description;
  @override
  Widget build(BuildContext context) {
    return CustomTile(
        child: Tooltip(
            message: AppLocalizations.of(context).soundPlayedWhen(description),
            child: ListTile(
              title: Text(
                name,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.7)),
              ),
              trailing: FilePickerButton(musicMode, description),
            )));
  }
}
