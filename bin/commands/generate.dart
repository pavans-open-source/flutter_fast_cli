import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:args/args.dart';
import '../commands/asset_generator.dart';

class Generate {
  onGenerate(ArgResults argResult) {
    if (argResult.wasParsed('generate')) {
      var generateOption = argResult['generate'];
      if (generateOption == null || generateOption == '') {
        print(
          red('Error: Please use flutter_fast -g [option]. Available options: assets/feature/library'),
        );
        return;
      }

      switch (generateOption) {
        case 'assets':
          print('Generating assets...');
          AssetGenerator().onGenerateAssets();
          break;
        case 'feature':
          print('Generating feature...');
          break;
        case 'library':
          print('Generating library...');
          break;
        default:
          print(red(
              'Invalid option specified for -g. Available options: assets, feature, library'));
          break;
      }
      return;
    } else {
      print('No command specified. Use --help or -h for available options.');
      return;
    }
  }

  _onGenerateLibrary() {}

  _onGenerateFeature() {}
}


/// Function to capitalize the first letter of a string.


/// Function to convert a string with underscores into camelCase.


/// Function to update the pubspec.yaml file with the new assets section.

/// Generate a Dart file for each feature with the asset paths.
