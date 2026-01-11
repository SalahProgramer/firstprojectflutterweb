import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';

class AudioHelper {
  SoLoud soLoud = SoLoud.instance;
  AudioSource? backgroundSource;
  SoundHandle? soundBackgroundHandle; //playing background

  AudioSource? coinSource;

  Future<void> initialize() async {
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
    if (!soLoud.isInitialized || backgroundSource == null) return;

    soundBackgroundHandle = await soLoud.play(backgroundSource!);
    soLoud.setProtectVoice(soundBackgroundHandle!, true);
  }

  void stopBackgroundAudio() {
    if (soundBackgroundHandle == null) {
      return;
    }
    soLoud.fadeVolume(soundBackgroundHandle!, 0.0, Duration(milliseconds: 500));
  }

  //---coin----------------------------------

  Future<void> playCoinAudio() async {
    if (!soLoud.isInitialized || coinSource == null) return;

    await soLoud.play(coinSource!);
  }
}
