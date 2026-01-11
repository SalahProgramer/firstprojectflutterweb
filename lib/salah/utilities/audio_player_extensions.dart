import 'package:audioplayers/audioplayers.dart';

String _normalizeAssetPath(String assetPath) {
  const prefix = 'assets/';
  if (assetPath.startsWith(prefix)) {
    return assetPath.substring(prefix.length);
  }
  return assetPath;
}

extension AudioPlayerAssetX on AudioPlayer {
  Future<void> playAsset(
    String assetPath, {
    double volume = 1.0,
    Duration? position,
    PlayerMode? mode,
  }) {
    return play(
      AssetSource(_normalizeAssetPath(assetPath)),
      volume: volume,
      position: position,
      mode: mode,
    );
  }
}
