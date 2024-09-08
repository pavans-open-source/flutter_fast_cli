import 'package:dcli/dcli.dart';

class Error {
  /// The function `throwIncorrectUsage` prints an error message and a suggestion in a specific format.
  /// 
  /// Args:
  ///   e (Object): The parameter `e` in the `throwIncorrectUsage` function is used to pass an object
  /// that represents the error or incorrect usage that occurred.
  ///   suggestion (String): The `suggestion` parameter is a string that provides guidance or advice on
  /// how to correct the incorrect usage indicated by the `e` object.
  static throwIncorrectUsage(Object e,String suggestion){
    print('\n${red(e.toString())}');
    print(
      '\n${orange(suggestion)}',
    );
  }
}