import 'dart:io';

import 'package:dcli/dcli.dart';

import '../logger/logger.dart';
import '../utils/formatters.dart';

class LibraryGenerator {
  
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
      final libraryTemplate = '''
class ${Formatters().capitalize(libraryName ?? '')} {}
''';

      final libraryFolder = '$pwd/lib/libraries';

      final libDir = Directory(libraryFolder);
      libDir.existsSync() ? null : libDir.create();

      Logger.logDebug('Creating library...');

      final libSubDir = Directory(
        '$libraryFolder/${Formatters().toCamelCase(libraryName ?? '')}',
      );
      libSubDir.createSync();

      final file = File(
          '$libraryFolder/$libraryName/${Formatters().toCamelCase(libraryName ?? '')}_library.dart');

      if (!file.existsSync()) file.createSync();

      file.writeAsStringSync(libraryTemplate);

      Logger.logSuccess('Created library...');
    } catch (e) {
      Logger.logError(e.toString());
    }
  }

}
