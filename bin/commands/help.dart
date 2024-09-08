import 'dart:io';

import 'package:args/args.dart';
import '../logger/logger.dart';

/// The `Help` class provides information on various command line options and exits the program.
class Help {
  onHelp(ArgResults argResult) {
    Logger.logCommand('\n-f feature_name : it is used to generate a feature');
    Logger.logCommand('-a assets: it is used to generate asset files');
    Logger.logCommand('-l library_name : it is used to generate library');
    Logger.logCommand('-h --help : it is used to get help\n');
    Logger.logCommand('-i : It initailizes your project with basic structure');
    exit(0);
  }
}
