import 'dart:developer' as developer;

class AppLogger {
  static void info(String message, {String tag = 'sabmero'}) {
    developer.log(message, name: tag);
  }

  static void error(
    String message, {
    String tag = 'sabmero',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message, {String tag = 'sabmero'}) {
    developer.log('[WARNING] $message', name: tag);
  }

  static void debug(String message, {String tag = 'sabmero'}) {
    assert(() {
      developer.log('[DEBUG] $message', name: tag);
      return true;
    }());
  }
}
