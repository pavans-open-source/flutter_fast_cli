import 'package:args/args.dart';

class Help {
  onHelp(ArgResults argResult) {
    if (argResult.wasParsed('help')) {
      print('Help was requested!');
      return;
    }
  }
}