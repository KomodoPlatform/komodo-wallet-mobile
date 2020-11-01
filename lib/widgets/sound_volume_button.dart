import 'package:flutter/material.dart';
import 'package:komodo_dex/services/music_service.dart';

/// Volume control shared between the swap page and the settings.
/// On - full volume.
/// Off - 1/10 of volume (note that we don't want to turn the sound off entirely,
///   cf. https://github.com/ca333/komodoDEX/pull/615#issuecomment-558355262).
class SoundVolumeButton extends StatefulWidget {
  const SoundVolumeButton({Key key}) : super(key: key);

  @override
  _SoundVolumeButtonState createState() => _SoundVolumeButtonState();
}

class _SoundVolumeButtonState extends State<SoundVolumeButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        key: const Key('sound-volume-button'),
        icon: Icon(Icons.audiotrack),
        color: musicService.on()
            ? Theme.of(context).toggleableActiveColor
            : Theme.of(context).textTheme.bodyText1.color,
        onPressed: () {
          setState(() {
            musicService.flip();
          });
        });
  }
}
