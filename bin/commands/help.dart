import 'dart:io';

import 'package:args/args.dart';
import '../logger/logger.dart';

class Help {
  onHelp(ArgResults argResult) {
    Logger.logCommand(
        '\n--feature [feature_name] : it is used to generate a feature');
    Logger.logCommand('--assets : it is used to generate asset files');
    Logger.logCommand(
        '--library [library_name] : it is used to generate library');
    Logger.logCommand('--help : it is used to get help');
    Logger.logCommand(
        '--initialize : It initailizes your project with basic structure');
    Logger.logCommand(
        '--cicd [provider_name] : It initailizes your project with CICD');
    exit(0);
  }
}
