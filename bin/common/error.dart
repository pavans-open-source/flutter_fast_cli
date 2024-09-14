import 'package:dcli/dcli.dart';

class Error {
  static throwIncorrectUsage(Object e,String suggestion){
    print('\n${red(e.toString())}');
    print(
      '\n${orange(suggestion)}',
    );
  }
}