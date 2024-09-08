import 'package:dcli/dcli.dart';

class Logger {
  static logError(String error) {
    print(red(error));
  }

  static logSuccess(String error) {
    print(green(error));
  }

  static logWarning(String error) {
    print(orange(error));
  }

  static logDebug(String error) {
    print(white(error));
  }

  static logCommand(String error) {
    print(blue(error));
  }
}
