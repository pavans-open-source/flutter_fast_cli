import 'package:dcli/dcli.dart';

import '../common/error.dart';
import '../commands/help.dart';
import '../commands/asset_generator.dart';
import 'package:args/args.dart';
import '../commands/generate.dart';

class Init {
  onInit(List<String> arguments) {
    _checkFlutter();
    _decodeArguments(arguments);
  }

  static ArgParser _initializeFlags() {
    var parser = ArgParser();
    parser.addFlag('help', abbr: 'h', help: 'Show available options');

    parser.addOption(
      'generate',
      mandatory: true,
      abbr: 'g',
      help: 'Generate assets/feature/library',
      allowed: [
        'assets',
        'library',
        'feature',
      ],
    );
    return parser;
  }

  static _runWithArgument(ArgResults argResult) {
    if (argResult.wasParsed('help')) Help().onHelp(argResult);
    if (argResult.wasParsed('generate')) Generate().onGenerate(argResult);
  }

  static _decodeArguments(List<String> arguments) {
    try {
      final parser = _initializeFlags();
      final argResult = parser.parse(arguments);
      _runWithArgument(argResult);
    } catch (e) {
      Error.throwIncorrectUsage(
        e.toString(),
        'usage : flutter_fast -g [options]  Available Options : assets/library/feature\n',
      );
      return;
    }
  }

  static void _checkFlutter() {
    try {
      if (which('flutter').found) {
        var flutterVer = 'flutter --version'.run as String;
        blue('Current Flutter version: $flutterVer');
      } else {
        print(orange('\nRunning Flutter Fast - Fast Faster Fastest'));
        print(
          white("\nLooks like Flutter wasn't found. Do you want to...",
              bold: false),
        );
        print(blue('\n1. Install Flutter'));
        print(blue('2. Add it to PATH'));

        final choice = ask(
          '\nChoose an option : ',
          validator: Ask.integer,
        );

        switch (choice) {
          case '1':
            _installFlutter();
            break;
          case '2':
            final path = ask('Enter the path: ');
            'export PATH=\$PATH:$path'
                .run; // Note: This will only affect the script, not the current shell session
            _checkFlutter(); // Recheck after modifying PATH
            break;
          default:
            red('Invalid choice. Please run the program again.');
        }
      }
      return;
    } catch (e) {
      red(e.toString());
      return;
    }
  }

  static void _installFlutter() {
    try {
      final pathExportCmd = 'export PATH="\$PATH:`pwd`/flutter/bin';

      green('\nInstalling Flutter, please wait...');

      final Progress cloneStatus =
          'git clone https://github.com/flutter/flutter.git -b stable'.start(
        runInShell: true,
        terminal: true,
      );

      if (cloneStatus.exitCode == 0) {
        final pathSet = pathExportCmd.start(
          terminal: true,
          runInShell: true,
        );
        if (pathSet.exitCode == 0) {
          'flutter doctor'.run;
        } else {
          print(
            red('\nSetting path was not completed, please re-run $pathExportCmd'),
          );
        }
      } else {
        print(
          red('\nSomething went wrong, Please run the command again.'),
        );
      }
      return;
    } catch (e) {
      red('\n${e.toString()}');
      return;
    }
  }
}
