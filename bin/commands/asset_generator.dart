import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:args/args.dart';

class AssetGenerator {
  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  String _toCamelCase(String str) {
    List<String> words = str.split('_');
    if (words.isEmpty) return str;

    // Lowercase the first word and capitalize the rest
    return words.asMap().entries.map((entry) {
      if (entry.key == 0) {
        return entry.value.toLowerCase();
      } else {
        return _capitalize(entry.value);
      }
    }).join('');
  }

  void _updatePubspec() async {
    final pubspecFile = File('pubspec.yaml');
    final backupFile = File('pubspec.yaml.bak');

    if (!await pubspecFile.exists()) {
      print('pubspec.yaml not found!');
      exit(1);
    }

    // Backup the original pubspec.yaml
    await pubspecFile.copy(backupFile.path);
    List<String> lines = await pubspecFile.readAsLines();

    // Create a temporary list to hold the new content
    List<String> newLines = [];
    bool inFlutterSection = false;

    for (var line in lines) {
      // Start writing to temp when we hit flutter section
      if (line.trim().startsWith('flutter:')) {
        inFlutterSection = true;
      }

      if (inFlutterSection && line.trim().startsWith('assets:')) {
        // Skip existing assets section
        while (line.isNotEmpty && line.trim().isNotEmpty) {
          line = (await pubspecFile.readAsLines())[newLines.length];
        }
        continue;
      }

      newLines.add(line);
    }

    // Add the new assets section
    newLines.add('  assets:');
    final assetDir = Directory('assets');

    if (await assetDir.exists()) {
      await for (var entity in assetDir.list()) {
        if (entity is Directory) {
          String featureName = entity.uri.pathSegments.last;
          newLines.add('    - assets/$featureName/icons/');
          newLines.add('    - assets/$featureName/images/');
        }
      }
    }

    // Write the updated content to pubspec.yaml
    await pubspecFile.writeAsString(newLines.join('\n'));

    print('pubspec.yaml updated successfully.');

    print('Generating files...');
  }

  void _generateDartFiles() async {
    final assetDir = Directory('assets');

    if (!await assetDir.exists()) {
      print('assets directory not found!');
      return;
    }

    await for (var featureDir in assetDir.list()) {
      if (featureDir is Directory) {
        String featureName = featureDir.uri.pathSegments.last;
        String capitalizedFeatureName = _capitalize(featureName);
        String outputFilePath =
            'lib/features/$featureName/static/assets/${featureName}_screen_assets.dart';

        // Create output directories if they don't exist
        File outputFile = File(outputFilePath);
        await outputFile.create(recursive: true);

        // Start writing the Dart file
        IOSink sink = outputFile.openWrite();
        sink.writeln('class ${capitalizedFeatureName}ScreenAssets {');

        // Add icon paths
        var iconsDir = Directory('${featureDir.path}/icons');
        if (await iconsDir.exists()) {
          await for (var icon in iconsDir.list()) {
            if (icon is File) {
              String iconName = icon.uri.pathSegments.last;
              String baseName = iconName.split('.').first;
              String camelCaseName = _toCamelCase(baseName);
              sink.writeln(
                  "  static const String $camelCaseName = 'assets/$featureName/icons/$iconName';");
            }
          }
        }

        // Add image paths
        var imagesDir = Directory('${featureDir.path}/images');
        if (await imagesDir.exists()) {
          await for (var image in imagesDir.list()) {
            if (image is File) {
              String imageName = image.uri.pathSegments.last;
              String baseName = imageName.split('.').first;
              String camelCaseName = _toCamelCase(baseName);
              sink.writeln(
                  "  static const String $camelCaseName = 'assets/$featureName/images/$imageName';");
            }
          }
        }

        sink.writeln('}');
        await sink.close();

        print('Generated Dart file: $outputFilePath');
      }
    }
  }

  onGenerateAssets() {
    _updatePubspec();
    _generateDartFiles();
  }
}
