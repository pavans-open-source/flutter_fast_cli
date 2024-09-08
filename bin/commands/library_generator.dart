import 'dart:io';

import 'package:dcli/dcli.dart';

import '../logger/logger.dart';
import '../utils/formatters.dart';

class LibraryGenerator {
  onGenerateLibrary(String? libraryName) {
    try {
      final libraryTemplate = '''
class $libraryName {}
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
