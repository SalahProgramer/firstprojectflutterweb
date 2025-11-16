import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Server running on http://localhost:8080');

  await for (HttpRequest request in server) {
    request.response
      ..write('Hello from Dart in Docker!')
      ..close();
  }
}
