import 'dart:io';

import 'package:dcli/dcli.dart';
import '../logger/logger.dart';
import '../commands/help.dart';
import 'package:args/args.dart';
import '../commands/generate.dart';
import '../commands/initialize.dart';

class Init {
  onInit(List<String> arguments) {
    _initialize(arguments);
  }

  static ArgParser _initializeFlags() {
    var parser = ArgParser();

    parser.addFlag(
      'help',
      abbr: 'h',
      help: 'Show available options',
    );

    parser.addFlag(
      'initialize',
      abbr: 'i',
      help: 'Show available options',
    );

    parser.addFlag(
      'asset',
      abbr: 'a',
      help: 'Show available options',
    );

    parser.addOption(
      'library',
      mandatory: true,
      abbr: 'l',
      // help: 'Generate assets/feature/library',
    );

    parser.addOption(
      'feature',
      mandatory: true,
      abbr: 'f',
      // help: 'Generate assets/feature/library',
    );
    return parser;
  }

  static _runWithArgument(ArgResults argResult) {
    if (argResult.wasParsed('asset')) {
      Generate().onAssetGenerate();
    } else if (argResult.wasParsed('library')) {
      Generate().onLibraryGenerate(argResult['library']);
    } else if (argResult.wasParsed('feature')) {
      Generate().onFeatureGenerate(argResult['feature']);
    } else if (argResult.wasParsed('help')) {
      Help().onHelp(argResult);
    } else if (argResult.wasParsed('initialize')) {
      Initialize().initializeFastStructure();
    }
  }

  static _parseArguments(List<String> arguments) {
    try {
      final parser = _initializeFlags();
      final argResult = parser.parse(arguments);
      _runWithArgument(argResult);
    } catch (e) {
      Logger.logError('${e.toString()}\n');
      Logger.logError(
        'usage : flutter_fast -g [options]  Available Options : assets/library/feature\n',
      );
      return;
    }
  }

  static void _initialize(List<String> arguments) {
    try {
      if (which('flutter').found) {
        if (arguments.isNotEmpty) _parseArguments(arguments);
        _parseArguments(['-h']);
      } else {
        // print(
        //   red(
        //     '\nFlutter is not installed... Please install it before proceeding',
        //   ),
        // );
        Logger.logWarning('\nRunning Flutter Fast - Fast Faster Fastest');
        Logger.logDebug(
          "\nLooks like Flutter wasn't found. Do you want to...",
        );
        Logger.logCommand('\n1. Install Flutter');
        Logger.logCommand('2. Add it to PATH');

        final choice = ask(
          '\nChoose an option : ',
          validator: Ask.integer,
        );

        switch (choice) {
          case '1':
            _installFlutter();
            break;

          case '2':
            final addedToPath = _addToPath(null);
            final isY =
                ask('\nDo you want to restart and apply changes..? [y/n]');
            isY.toLowerCase() == 'y' && addedToPath
                ? _initialize(arguments)
                : exit(0);
            break;

          default:
            Logger.logWarning(
              'Invalid choice. Please run the program again.',
            );
        }
      }
    } catch (e) {
      Logger.logWarning(e.toString());
    }
  }

  static void _installFlutter() {
    try {
      Logger.logSuccess(
        '\nInstalling Flutter, please wait...',
      );

      final Progress cloneStatus =
          'git clone https://github.com/flutter/flutter.git -b stable'.start(
        runInShell: true,
        terminal: true,
      );

      if (cloneStatus.exitCode == 0) {
        final pathSet = _addToPath('$pwd/flutter/bin');
        if (pathSet) {
          'flutter doctor'.run;
        }
      } else {
        Logger.logWarning(
          '\nSomething went wrong, Please run the command again.',
        );
      }
    } catch (e) {
      Logger.logWarning(
        '\n${e.toString()}',
      );
    }
  }

  static bool _addToPath(String? path) {
    final currPath = path ?? ask('Enter the path: ');

    if (Directory(currPath).existsSync()) {
      // Update .bashrc, .zshrc, or similar to persist the path
      final homeDir = env['HOME'];
      final shellConfigFile = File('$homeDir/.bashrc');
      shellConfigFile.writeAsStringSync(
        '\nexport PATH=\$PATH:$currPath',
        mode: FileMode.append,
      );
      Logger.logSuccess(
        '\n$currPath was added to PATH',
      );
      return true;
    } else {
      Logger.logWarning('\nInvalid path, please check again.\n');
      Logger.logDebug(
        'Please re-run [export PATH=\$PATH:$currPath] manually...\n',
      );
      return false;
    }
  }
}
