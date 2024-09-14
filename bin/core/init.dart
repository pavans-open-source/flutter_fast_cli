import 'dart:io';
import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import '../logger/logger.dart';
import '../commands/help.dart';
import '../commands/initialize_fast.dart';
import '../commands/asset_generator.dart';
import '../commands/feature_generator.dart';
import '../commands/library_generator.dart';
import '../commands/flavor_generator.dart';

class Init {
  onInit(List<String> arguments) {
    // _pthreadMutex();
    ArgParser parser = _initializeFlags();
    _decodeArgumentRunCmd(parser, arguments);
    Logger.logWarning('\nRunning Flutter Fast - Fast Faster Fastest');
    bool flutterInstalled = _checkFlutter();
    if (!flutterInstalled) {
      _askToInstallFlutter(arguments);
      exit(0);
    }
  }

  // _pthreadMutex() {
  //   if (Platform.isMacOS || Platform.isLinux) {
  //     try {
  //       var pthread = ffi.DynamicLibrary.open('libpthread.so');
  //       // Attempt to call pthread_mutex_timedlock
  //     } catch (e) {
  //       print('pthread_mutex_timedlock not available: $e');
  //     }
  //   } else if (Platform.isWindows) {
  //     print('Windows detected, skipping POSIX-specific functionality.');
  //   }
  // }

  ArgParser _initializeFlags() {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Show help message.')
      ..addOption('asset', abbr: 'g', help: 'Generate assets.')
      ..addOption('library', abbr: 'l', help: 'Generate a new library.')
      ..addOption('feature', abbr: 'f', help: 'Generate a new feature.')
      ..addFlag(
        'init',
        abbr: 'i',
        negatable: false,
        help: 'Initialize project structure.',
      )
      ..addMultiOption(
        'flavors',
        abbr: 'v',
        help: 'Generate flavors for the project.',
      );

    return parser;
  }

  _decodeArgumentRunCmd(
    ArgParser parser,
    List<String> arguments,
  ) {
    try {
      final argResult = parser.parse(arguments);
      if (argResult.option('asset')?.isNotEmpty ?? false) {
        AssetGenerator().onGenerateAssets();
      } else if (argResult.option('library')?.isNotEmpty ?? false) {
        final libraryName = argResult['library'];
        LibraryGenerator().onGenerateLibrary(libraryName);
      } else if (argResult.option('feature')?.isNotEmpty ?? false) {
        final featureName = argResult['feature'];
        FeatureGenerator().onGenerateFeature(featureName);
      } else if (argResult.flag('help')) {
        Help().onHelp(argResult);
      } else if (argResult.flag('init')) {
        InitializeFast().initializeFastStructure();
      } else if (argResult.multiOption('flavors').isNotEmpty) {
        List<String> flavors = argResult['flavors'];
        FlavorGenerator().onGenerateFlavors(flavors);
      }
    } catch (e) {
      Logger.logError('${e.toString()}\n');
      Logger.logError(
        'usage : flutter_fast -h for help \n',
      );
    }
  }

  bool _checkFlutter() {
    Logger.logDebug('Checking flutter...');
    bool flutterInstalled = which('flutter', verbose: true).found;
    flutterInstalled
        ? Logger.logSuccess('\nFlutter found..!')
        : Logger.logError('Flutter not found.\n');
    return flutterInstalled;
  }

  void _installFlutter() {
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

  void _askToInstallFlutter(List<String> arguments) {
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
        final isY = ask('\nDo you want to restart and apply changes..? [y/n]');
        isY.toLowerCase() == 'y' && addedToPath ? onInit(arguments) : exit(0);
        break;

      default:
        Logger.logWarning(
          'Invalid choice. Please run the program again.',
        );
    }
  }

  bool _addToPath(String? path) {
    final currPath = path ?? ask('Enter the path: ');

    if (Directory(currPath).existsSync()) {
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
