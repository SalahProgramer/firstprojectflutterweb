import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isConnectedWifi() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult.contains(ConnectivityResult.wifi) ||
      connectivityResult.contains(ConnectivityResult.ethernet) ||
      connectivityResult.contains(ConnectivityResult.mobile);
}
