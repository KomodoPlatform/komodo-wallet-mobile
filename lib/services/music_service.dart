import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:path_provider/path_provider.dart';

import 'mm_service.dart';

MusicService musicService = MusicService();

enum MusicMode {
  /// Trying to match with an existing order.
  TAKER,

  /// Having orders.
  MAKER,

  /// There are active swaps.
  ACTIVE,

  /// There was a failed swap recently.
  FAILED,

  /// There was a finished swap recently.
  APPLAUSE,

  /// No active orders or swaps, we can stay silent
  /// (and allow the application to be suspended, saving battery life).
  SILENT
}

/// Allows iOS application instances to stay alive in background.
class MusicService {
  MusicService() {
    getApplicationDocumentsDirectory().then((docs) {
      _docs = docs;
    });
    makePlayer();
  }

  /// Initially `null` (unknown) in order to trigger `recommendsPeriodicUpdates`.
  MusicMode musicMode;

  /// Whether the volume is currently up.
  bool _on = true;

  /// Application directory, with `_customName` files in it.
  Directory _docs;

  /// Triggers reconfiguration of the player.
  bool _reload = false;

  AudioPlayer _audioPlayer;
  AudioCache _player;

  void makePlayer() {
    _audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    _player = AudioCache(prefix: 'audio/', fixedPlayer: _audioPlayer);

    _audioPlayer.onPlayerError.listen((String ev) {
      Log('music_service:68', 'onPlayerError: ' + ev);
    });

    /*
    _audioPlayer.onPlayerCompletion.listen((_) {
      // Happens when a music (mp3) file is finished, multiple times when we're using a `loop`.
      //Log('music_service:74', 'onPlayerCompletion');
    });
    */
  }

  /// Pick the current music mode based on the list of all the orders and SWAPs.
  MusicMode pickMode(List<Order> orders) {
    for (final Swap swap in syncSwaps.swaps) {
      final String uuid = swap.result.uuid;
      final String shortId = uuid.substring(0, 4);
      final bool active = swap.status != Status.SWAP_FAILED &&
          swap.status != Status.SWAP_SUCCESSFUL &&
          swap.status != Status.TIME_OUT;
      if (active) {
        Log('music_service:88',
            'pickMode] swap $shortId status: ${swap.status}, MusicMode.ACTIVE');
        return MusicMode.ACTIVE;
      }

      if (musicMode == MusicMode.ACTIVE) {
        if (swap.status == Status.SWAP_FAILED ||
            swap.status == Status.TIME_OUT) {
          Log('music_service:96',
              'pickMode] failed swap $shortId, MusicMode.FAILED');
          return MusicMode.FAILED;
        } else if (swap.status == Status.SWAP_SUCCESSFUL) {
          Log('music_service:100',
              'pickMode] finished swap $shortId, MusicMode.APPLAUSE');
          return MusicMode.APPLAUSE;
        }
      }
    }

    for (final Order order in orders) {
      final String shortId = order.uuid.substring(0, 4);
      if (order.orderType == OrderType.TAKER) {
        Log('music_service:110',
            'pickMode] taker order $shortId, MusicMode.TAKER');
        return MusicMode.TAKER;
      } else if (order.orderType == OrderType.MAKER) {
        Log('music_service:114',
            'pickMode] maker order $shortId, MusicMode.MAKER');
        return MusicMode.MAKER;
      }
    }

    Log('music_service:120',
        'pickMode] no active orders or swaps, MusicMode.SILENT');
    return MusicMode.SILENT;
  }

  String _customName(MusicMode mode) => mode == MusicMode.TAKER
      ? 'taker.mp3'
      : mode == MusicMode.MAKER
          ? 'maker.mp3'
          : mode == MusicMode.ACTIVE
              ? 'active.mp3'
              : mode == MusicMode.FAILED
                  ? 'failed.mp3'
                  : mode == MusicMode.APPLAUSE ? 'applause.mp3' : null;

  Future<void> setSoundPath(MusicMode mode, String path) async {
    final String name = _customName(mode);
    if (name == null) throw Exception('unexpected mode: $mode');

    // NB: In my experience on iOS the `path` points into an "Inbox" application directory.
    // "Your app can read and delete files in this directory but cannot create new files
    // or write to existing files. If the user tries to edit a file in this directory,
    // your app must silently move it out of the directory before making any changes."
    // - https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html

    if (_docs == null) throw Exception('Application directory is missing');
    final String target = _docs.path.toString() + '/' + name;
    final File file = File(path);
    Log('music_service:148', 'copying $path to $target');
    await file.copy(target);

    _reload = true;
  }

  // First batch of audio files was gathered by the various members of Komodo team
  // and had funny names testimony to the gay variety of places it came from:
  // 15427__lg__fax, Coin_Drop-Willem_Hunt-569197907, 162196__rickmk2__coin-rustle,
  // 362272__zabuhailo__street-musician-money, 376196__euphrosyyn__futuristic-robotic-voice-sentences,
  // 213901__garzul__robotic-arp-sequence, Cash-Register-Cha-Ching-SoundBible.com-184076484,
  // poker-chips-daniel_simon
  // We did a pair programming session on classifying that music
  // and it was a bit of a surprise that every one of them has fallen into a place.
  //
  // If we are to expand the collection of audio tracks
  // then the idea is to have some default tracks in the application bundle
  // (just to minimally cover all the modes)
  // and download the extra tracks on demand from an external server
  // in order to keep the application bundle (and Git repository) small.

  void play(List<Order> orders) {
    // ^ Triggered by page transitions and certain log events (via `onLogsmm2`),
    //   but for reliability we should also add a periodic update independent from MM logs.
    final MusicMode newMode = pickMode(orders);
    bool changes = false;

    if (newMode != musicMode) {
      changes = true;
      Log('music_service:177', 'play] $musicMode -> $newMode');
    }

    if (_reload) {
      _reload = false;
      // Recreating the player in order for it not to use a previous instance of the sound file.
      _audioPlayer.stop();
      _audioPlayer.release();
      _player.clearCache();
      makePlayer();
      changes = true;
    }

    if (!changes) return;

    // Switch to a custom sound file if it is present in the docs.
    File customFile;
    final String customName = _customName(newMode);
    if (_docs != null && customName != null) {
      final File custom = File(_docs.path.toString() + '/' + customName);
      if (custom.existsSync()) customFile = custom;
    }

    final Random rng = Random();

    final String defaultPath = newMode == MusicMode.TAKER
        ? (rng.nextBool() ? 'taker1.mp3' : 'taker2.mp3')
        : newMode == MusicMode.MAKER
            ? 'maker.mp3'
            : newMode == MusicMode.ACTIVE
                ? 'active.mp3'
                : newMode == MusicMode.FAILED
                    ? (rng.nextBool() ? 'failed1.mp3' : 'failed2.mp3')
                    : newMode == MusicMode.APPLAUSE
                        ? 'applause.mp3'
                        : newMode == MusicMode.SILENT ? 'lastSound.mp3' : null;

    final String path = customFile != null ? customFile.path : defaultPath;
    Log('music_service:215', 'path: $path');

    // Tell the player how to access the file directly instead of trying to copy it from the assets.
    if (customFile != null) _player.loadedFiles[customFile.path] = customFile;

    if (newMode == MusicMode.TAKER) {
      _player.loop(path, volume: volume());
    } else if (newMode == MusicMode.MAKER) {
      _player.loop(path, volume: volume());
    } else if (newMode == MusicMode.ACTIVE) {
      _player.loop(path, volume: volume());
    } else if (newMode == MusicMode.FAILED) {
      _audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
      _player.play(path, volume: volume());
    } else if (newMode == MusicMode.APPLAUSE) {
      _audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
      _player.play(path, volume: volume());
    } else if (newMode == MusicMode.SILENT) {
      _audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
      _player.play(path, volume: volume());
    } else {
      Log('music_service:236', 'Unexpected music mode: $newMode');
      _audioPlayer.stop();
    }

    musicMode = newMode;
  }

  /// True when we want to periodically update the orders and swaps.
  ///
  /// As of now the lists of orders and swaps are not a part of a separate model
  /// but are instead embedded into the UI orders and swap history blocks.
  /// This results in unreliable updates of those list
  /// as the said updates either aren't triggered when these blocks are not visible
  /// or triggered belatedly and out of order, during UI transitions and such.
  ///
  /// Hence when the music is playing we want to also trigger an update of these list with a separate timer.
  ///
  /// We also want an update whenever the `musicMode` is unknown,
  /// which happens after the application restarts.
  bool recommendsPeriodicUpdates() {
    return musicMode != MusicMode.SILENT || _reload;
  }

  /// Whether the application shold `exit` when it goes to "background".
  /// If there are active orders and swaps then we should be playing a sound and staying alive in background.
  /// If there are none then we should `exit` in order to avoid mysterious screen flickers and crashes.
  /// cf. https://github.com/ca333/komodoDEX/issues/658#issuecomment-583005596
  /// https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background
  Future<bool> iosBackgroundExit() async {
    final double btr =
        await MMService.nativeC.invokeMethod('backgroundTimeRemaining');
    Log('music_service:267', 'backgroundTimeRemaining: $btr');

    // When `MusicService` is playing the music the `backgroundTimeRemaining` is large
    // and when we are silent the `backgroundTimeRemaining` is low
    // (expected low values are ~5, ~180, ~600 seconds).
    // #658: We should only remain in background if we're going to keep playing the sounds.
    if (btr > 3600 &&
        (musicMode == MusicMode.ACTIVE ||
            musicMode == MusicMode.MAKER ||
            musicMode == MusicMode.TAKER)) return false;

    // Known cases of when "background" doesn't necessarily means "suspend".
    if (mainBloc.isUrlLaucherIsOpen) return false;
    if (lockService.inQrScanner) return false;
    if (lockService.inFilePicker) return false;
    return true;
  }

  /// Current audio player volume, from 0 to 1, based on the `on` switch.
  double volume() {
    // AG: We don't want the volume to be *too* low
    // for otherwise reviewers might think that we're using the infamous silent audio trick.
    return _on ? 1 : 0.1;
  }

  /// True if the music volume is currently up.
  bool on() {
    return _on;
  }

  /// Tune the volume down or back up.
  void flip() {
    _on = !_on;
    _audioPlayer.setVolume(volume());
  }
}
