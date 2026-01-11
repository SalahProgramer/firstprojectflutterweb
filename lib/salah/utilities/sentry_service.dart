import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static Future<void> init({
    required FutureOr<void> Function()? appRunner,
  }) async {
    await SentryFlutter.init((options) {
      options.dsn = (kReleaseMode)
          ? 'https://eb2f8855fc97a74a3310f326142eace0@o4509734429130752.ingest.us.sentry.io/4509734434439168'
          : "";
      options.sendDefaultPii = true;
      options.replay.sessionSampleRate = 1.0;
      options.replay.onErrorSampleRate = 1.0;
      options.attachStacktrace = true;
      options.tracesSampleRate = 1.0;
      options.debug = false;

      // Set to true for development debugging
    }, appRunner: appRunner);
  }

  static Future<void> captureError({
    required dynamic exception,
    dynamic stackTrace,
    String? functionName,
    String? fileName,
    int? lineNumber,
    bool isCaptured = true,
    Map<String, dynamic>? extraData,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setContexts('Fawri app extra data', {
          "functionName": functionName,
          "fileName": fileName,
          "lineNumber": lineNumber,
          "isCaptured": isCaptured,
          "timestamp": DateTime.now().toIso8601String(),
          ...?extraData,
        });
        scope.setTag('function', functionName ?? 'unknown');
        scope.setTag('file', fileName ?? 'unknown');
      },
    );
  }

  // static Future<void> captureMessage(
  //     {required String message,
  //     String? functionName,
  //     String? fileName,
  //     int? lineNumber,
  //     SentryLevel level = SentryLevel.info,
  //     Map<String, dynamic>? extraData}) async {
  //   await Sentry.captureMessage(message, level: level,
  //       withScope: (Scope scope) {
  //     scope.setContexts('Fawri app message data', {
  //       "functionName": functionName,
  //       "fileName": fileName,
  //       "lineNumber": lineNumber,
  //       "timestamp": DateTime.now().toIso8601String(),
  //       ...?extraData,
  //     });
  //     scope.setTag('function', functionName ?? 'unknown');
  //     scope.setTag('file', fileName ?? 'unknown');
  //   });
  // }

  // static Future<ISentrySpan?> startTransaction(
  //     {required String name,
  //     required String operation,
  //     String? description}) async {
  //   return await Sentry.startTransaction(
  //     name,
  //     operation,
  //     description: description,
  //   );
  // }

  // static Future<void> addBreadcrumb(
  //     {required String message,
  //     String? category,
  //     String? type,
  //     Map<String, dynamic>? data}) async {
  //   await Sentry.addBreadcrumb(
  //     Breadcrumb(
  //       message: message,
  //       category: category,
  //       type: type,
  //       data: data,
  //       timestamp: DateTime.now(),
  //     ),
  //   );
  // }

  // static Future<void> setUser({
  //   String? id,
  //   String? email,
  //   String? username,
  //   Map<String, dynamic>? extras,
  // }) async {
  //   await Sentry.configureScope((scope) {
  //     scope.setUser(SentryUser(
  //       id: id,
  //       email: email,
  //       username: username,
  //       extras: extras,
  //     ));
  //   });
  // }

  // static Future<void> setTag(String key, String value) async {
  //   await Sentry.configureScope((scope) {
  //     scope.setTag(key, value);
  //   });
  // }

  // static Future<void> setExtra(String key, dynamic value) async {
  //   await Sentry.configureScope((scope) {
  //     scope.setExtra(key, value);
  //   });
  // }
}
