import 'package:get_it/get_it.dart';

import '../../games/audio_helper.dart';

final getIt = GetIt.instance;
Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<AudioHelper>(() => AudioHelper());
}
