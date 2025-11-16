import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fawri_app_refactor/gen/assets.gen.dart';

class AudioHelper {
  SoLoud soLoud = SoLoud.instance;
  AudioSource? backgroundSource;
  SoundHandle? soundBackgroundHandle; //playing background

  AudioSource? coinSource;

  Future<void> initialize() async {
    // Skip audio initialization on web to avoid plugin issues
    if (kIsWeb) {
      return;
    }
    soLoud = SoLoud.instance;
    if (soLoud.isInitialized) {
      return;
    }
    await soLoud.init();
    backgroundSource = await soLoud.loadAsset(Assets.audios.musicBackground);

    coinSource = await soLoud.loadAsset(Assets.audios.coins);
  }

//----background---------------------------

  Future<void> playBackgroundAudio() async {
    if (kIsWeb) return;
    if (!soLoud.isInitialized || backgroundSource == null) return;

    soundBackgroundHandle = await soLoud.play(backgroundSource!);
    soLoud.setProtectVoice(soundBackgroundHandle!, true);
  }

  void stopBackgroundAudio() {
    if (kIsWeb) return;
    if (soundBackgroundHandle == null) {
      return;
    }
    soLoud.fadeVolume(soundBackgroundHandle!, 0.0, Duration(milliseconds: 500));
  }

//---coin----------------------------------

  Future<void> playCoinAudio() async {
    if (kIsWeb) return;
    if (!soLoud.isInitialized || coinSource == null) return;

    await soLoud.play(coinSource!);
  }
}
