import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import '../model/order.dart';
import '../model/swap.dart';
import '../model/swap_provider.dart';
import '../utils/log.dart';
import '../utils/utils.dart';

import 'mm_service.dart';

MusicService musicService = MusicService();

enum MusicMode {
  /// Trying to match with an existing order.
  TAKER,

  /// Having orders.
  MAKER,

  /// There are active swaps or zcash is installing.
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
    applicationDocumentsDirectory.then((docs) {
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

  Iterable<Swap> _successfulSwaps;
  Iterable<Swap> _failedSwaps;

  void makePlayer() {
    // On iOS we're using the “audio.m” implementation instead.
    if (!Platform.isAndroid) return;

    _audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    _player = AudioCache(prefix: 'assets/audio/', fixedPlayer: _audioPlayer);

    _audioPlayer.onPlayerError.listen((String ev) {
      Log('music_service:72', 'onPlayerError: ' + ev);
    });

    /*
    _audioPlayer.onPlayerCompletion.listen((_) {
      // Happens when a music (mp3) file is finished, multiple times when we're using a `loop`.
      //Log('music_service:78', 'onPlayerCompletion');
    });
    */
  }

  /// Pick the current music mode based on the list of all the orders and SWAPs.
  MusicMode pickMode(List<Order> orders) {
    MusicMode prevMode = musicMode;
    // if (zcashBloc.tasksToCheck.isNotEmpty) return MusicMode.ACTIVE;
    if (prevMode == MusicMode.ACTIVE && _anyNewSuccessfulSwaps()) {
      Log('music_service]', 'pickMode: MusicMode.APPLAUSE');
      return MusicMode.APPLAUSE;
    }

    if (prevMode == MusicMode.ACTIVE && _anyNewFailedSwaps()) {
      Log('music_service]', 'pickMode: MusicMode.FAILED');
      return MusicMode.FAILED;
    }

    for (final Order order in orders) {
      final String shortId = order.uuid.substring(0, 4);
      if (order.orderType == OrderType.MAKER) {
        Log('music_service:118',
            'pickMode] maker order $shortId, MusicMode.MAKER');
        return MusicMode.MAKER;
      } else if (prevMode != MusicMode.MAKER &&
          order.orderType == OrderType.TAKER) {
        Log('music_service:114',
            'pickMode] taker order $shortId, MusicMode.TAKER');
        return MusicMode.TAKER;
      }
    }

    for (final Swap swap in swapMonitor.swaps) {
      final String uuid = swap.result.uuid;
      final String shortId = uuid.substring(0, 4);

      final bool active = swap.status != Status.SWAP_FAILED &&
          swap.status != Status.SWAP_SUCCESSFUL &&
          swap.status != Status.TIME_OUT;
      if (active) {
        Log('music_service:92',
            'pickMode] swap $shortId status: ${swap.status}, MusicMode.ACTIVE');
        return MusicMode.ACTIVE;
      }
    }

    Log('music_service:124',
        'pickMode] no active orders or swaps, MusicMode.SILENT');
    return MusicMode.SILENT;
  }

  bool _anyNewSuccessfulSwaps() {
    final Iterable<Swap> successfulNew = swapMonitor.swaps
        .where((Swap swap) => swap.status == Status.SWAP_SUCCESSFUL);

    bool haveNew = false;
    if (_successfulSwaps != null && successfulNew != null) {
      haveNew = _successfulSwaps.length < successfulNew.length;
    }

    _successfulSwaps = successfulNew;
    return haveNew;
  }

  bool _anyNewFailedSwaps() {
    final Iterable<Swap> failedNew = swapMonitor.swaps.where((Swap swap) =>
        swap.status == Status.SWAP_FAILED || swap.status == Status.TIME_OUT);

    bool haveNew = false;
    if (_failedSwaps != null && failedNew != null) {
      haveNew = _failedSwaps.length < failedNew.length;
    }

    _failedSwaps = failedNew;
    return haveNew;
  }

  String _customName(MusicMode mode) => mode == MusicMode.TAKER
      ? 'tick-tock.mp3'
      : mode == MusicMode.MAKER
          ? 'maker_order_placed.mp3'
          : mode == MusicMode.ACTIVE
              ? 'swap_in_progress.mp3'
              : mode == MusicMode.FAILED
                  ? 'swap_failed.mp3'
                  : mode == MusicMode.APPLAUSE
                      ? 'swap_successful.mp3'
                      : null;

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
    Log('music_service:152', 'copying $path to $target');
    await file.copy(target);

    // Play the file right away to see if we can.
    // TBD: Idealy we'd automatically detect whether playing the file produces a sound,
    // but doing it complicated, plus some sound files might be intentionally silent.
    if (Platform.isIOS) {
      final rc = await MMService.nativeC
          .invokeMethod<int>('audio_fg', <String, dynamic>{'path': name});
      Log('music_service:161', 'audio_fg rc: $rc');
    }

    _reload = true;
  }

  Future<void> play(MusicMode newMode) async {
    // ^ Triggered by page transitions and certain log events (via `onLogsmm2`),
    //   but for reliability we should also add a periodic update independent from MM logs.

    bool changes = false;

    if (newMode != musicMode) {
      changes = true;
      Log('music_service:191', 'play] $musicMode -> $newMode');
    }

    if (_reload) {
      _reload = false;
      // Recreating the player in order for it not to use a previous instance of the sound file.
      if (Platform.isAndroid) {
        _audioPlayer.stop();
        _audioPlayer.release();
        _player.clearAll();
        makePlayer();
      }
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

    const String defaultPath = 'none.mp3';

    final String path = customFile != null
        ? (Platform.isAndroid ? customFile.path : customName)
        : defaultPath;
    Log('music_service:233', 'path: $path');

    if (Platform.isAndroid) {
      // Tell the player how to access the file directly instead of trying to copy it from the assets.
      if (customFile != null)
        _player.loadedFiles[customFile.path] = Uri.file(customFile.path);

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
        Log('music_service:255', 'Unexpected music mode: $newMode');
        _audioPlayer.stop();
      }
    } else {
      await MMService.nativeC.invokeMethod<int>('audio_volume', volume());

      if (newMode == MusicMode.APPLAUSE || newMode == MusicMode.FAILED) {
        // Play the file in the foreground once, then continue looping the background file.
        // NB: As of now the next invocation of `play` is likely to prematurely overwrite the queue.
        //     We should probably refactor `pickMode` to pick both the foreground and next background modes,
        //     and submit *both* to `audio_fg`,
        //     and then set the `musicMode` to the next background mode.
        final rc = await MMService.nativeC
            .invokeMethod<int>('audio_fg', <String, dynamic>{'path': path});
        if (rc != 0) Log('music_service:269', 'audio_fg rc: $rc');
      } else if (newMode == MusicMode.SILENT) {
        final int response =
            await MMService.nativeC.invokeMethod<int>('audio_stop');
        if (response != 0) Log('music_service', 'audio_stop: $response');
      } else {
        // Loop the file in background.
        final rc = await MMService.nativeC
            .invokeMethod<int>('audio_bg', <String, dynamic>{'path': path});
        if (rc != 0) Log('music_service:283', 'audio_bg rc: $rc');
      }
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
  bool get recommendsPeriodicUpdates => _reload;

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
    if (Platform.isAndroid) {
      _audioPlayer.setVolume(volume());
    } else {
      () async {
        await MMService.nativeC.invokeMethod<int>('audio_volume', volume());
      }();
    }
  }
}
