import 'dart:io';

import 'package:dcli/dcli.dart';

import '../logger/logger.dart';
import '../utils/formatters.dart';

class LibraryGenerator {
  String libraryFolder = '$pwd/lib/libraries';
  final libDir = Directory('$pwd/lib/libraries');

  /// The function `onGenerateLibrary` generates a Dart library with a specified name and saves it in a
  /// specific directory structure.
  ///
  /// Args:
  ///   libraryName (String): The `onGenerateLibrary` function takes a `libraryName` parameter, which is
  /// used to generate a library template in Dart. The function creates a class inside a library folder
  /// based on the provided `libraryName`. If `libraryName` is not provided, it defaults to an empty
  /// string.
  onGenerateLibrary(String? libraryName) {
    try {
      bool alreadyExist = _checkLibraryExists(libraryName);
      alreadyExist
          ? _askToOverride(libraryName!)
          : _writeContentInLibrary(libraryName!);
    } catch (e) {
      Logger.logError(e.toString());
    }
  }

  _askToOverride(String libraryName) {
    String isY = ask(
      'Do you want to re-write the library $libraryName [y/n] : ',
      toLower: true,
    );
    if (isY == 'y') {
      _writeContentInLibrary(libraryName);
    } else {
      exit(0);
    }
  }

  _checkLibraryExists(String? libraryName) {
    bool doesExist = libDir.existsSync();
    return doesExist;
  }

  _writeContentInLibrary(String libraryName) {
    final file = File(
      '$libraryFolder/$libraryName/${Formatters().toCamelCase(libraryName)}_library.dart',
    );
    final libraryTemplate = '''
class ${Formatters().capitalize(libraryName)} {}
''';

    Logger.logDebug('Creating library...');

    file.existsSync() ? null : file.createSync(recursive: true);
    file.writeAsStringSync(libraryTemplate);
    Logger.logSuccess('Created library...');
  }
}
