import 'dart:io';

import 'package:dcli/dcli.dart';
import '../logger/logger.dart';
import '../commands/help.dart';
import 'package:args/args.dart';
import '../commands/generate.dart';
import '../commands/initialize.dart';

class Init {
  /// The `onInit` function initializes with a list of string arguments.
  /// 
  /// Args:
  ///   arguments (List<String>): The `onInit` function takes a list of strings as a parameter named
  /// `arguments`. This list is used to initialize the function by passing any necessary arguments or
  /// configuration settings.
  onInit(List<String> arguments) {
    _initialize(arguments);
  }

/// The function `_initializeFlags` creates an ArgParser with flags and options for handling command
/// line arguments in Dart.
/// 
/// Returns:
///   The code snippet is defining a function named `_initializeFlags` that creates an instance of
/// `ArgParser`, adds flags and options to it, and then returns the `ArgParser` object. The function is
/// essentially initializing and setting up command line flags and options for parsing command line
/// arguments.
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

/// The `_runWithArgument` function processes command line arguments to trigger specific generation or
/// initialization tasks.
/// 
/// Args:
///   argResult (ArgResults): The `_runWithArgument` method takes an `ArgResults` object named
/// `argResult` as a parameter. This object is used to check which command-line arguments were parsed
/// and then execute corresponding actions based on the parsed arguments. The method checks for various
/// parsed arguments such as 'asset', 'library
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

/// The `_parseArguments` function in Dart parses command line arguments using a parser and runs a
/// function based on the parsed arguments, logging errors if any occur.
/// 
/// Args:
///   arguments (List<String>): The `_parseArguments` function takes a list of strings `arguments` as
/// input. These arguments are typically command-line arguments passed to the program when it is
/// executed. The function attempts to parse and process these arguments using a parser initialized by
/// `_initializeFlags()` function. If any error occurs during parsing or
/// 
/// Returns:
///   The `_parseArguments` method is returning `null` because there is no explicit return value
/// specified in the method.
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

/// The _initialize function checks for the presence of Flutter, prompts the user to install or add it
/// to PATH if not found, and handles user choices accordingly.
/// 
/// Args:
///   arguments (List<String>): The `_initialize` function in your code snippet takes a `List<String>`
/// named `arguments` as a parameter. This function checks if Flutter is installed by looking for the
/// 'flutter' command. If Flutter is found, it parses the arguments passed to the function and then
/// calls `_parseArguments(['-
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
