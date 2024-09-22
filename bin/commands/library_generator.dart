import 'dart:io';
import 'package:dcli/dcli.dart';
import '../logger/logger.dart';
import '../utils/formatters.dart';

class LibraryGenerator {
  final String libraryFolder = '$pwd/lib/libraries';
  final Directory libDir = Directory('$pwd/lib/libraries');

  void onGenerateLibrary(String? libraryName) {
    if (libraryName == null || libraryName.isEmpty) {
      Logger.logError('Library name cannot be null or empty.');
      exit(1);
    }

    try {
      if (_checkLibraryExists(libraryName)) {
        _askToOverride(libraryName);
      } else {
        _writeContentInLibrary(libraryName);
      }
    } catch (e) {
      Logger.logError('Error generating library: ${e.toString()}');
    }
  }

  void _askToOverride(String libraryName) {
    String response = ask(
      'The library "$libraryName" already exists. Do you want to overwrite it? [y/n]: ',
      toLower: true,
    );

    if (response == 'y') {
      Logger.logDebug('Overwriting existing library...');
      _writeContentInLibrary(libraryName);
    } else {
      Logger.logError('Operation canceled by the user.');
      exit(0);
    }
  }

  bool _checkLibraryExists(String libraryName) {
    bool doesExist = Directory('${libDir.path}/$libraryName').existsSync();
    Logger.logDebug('Checking if library exists: $doesExist');
    return doesExist;
  }

  void _writeContentInLibrary(String libraryName) {
    try {
      final filePath =
          '$libraryFolder/$libraryName/${Formatters().toCamelCase(libraryName)}_library.dart';
      final file = File(filePath);
      final libraryTemplate = '''
class ${Formatters().capitalize(libraryName)} {
  // Add your library code here
}
''';

      Logger.logDebug('Creating library directory and file: $filePath');

      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      file.writeAsStringSync(libraryTemplate);
      Logger.logSuccess('Library "$libraryName" created successfully.');
    } catch (e) {
      Logger.logError('Failed to write library content: ${e.toString()}');
    }
  }
}
