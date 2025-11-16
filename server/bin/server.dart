import 'dart:io';

void main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('Server running on http://localhost:$port');

  await for (HttpRequest request in server) {
    request.response
      ..write('Hello from Dart in Docker!')
      ..close();
  }
}
