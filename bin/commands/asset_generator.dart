import 'dart:io';
import 'package:dcli/dcli.dart'; // Ensure dcli is imported

import '../logger/logger.dart';
import '../utils/formatters.dart';

class AssetGenerator {
  // Helper function to capitalize strings

  // Helper function to convert snake_case to camelCase

  // Update or create assets section in pubspec.yaml
  void _updatePubspecAndGenerateFiles() {
    final pubspecFile = File('$pwd/pubspec.yaml');
    final backupFile = File('$pwd/pubspec.yaml.bak');

    Logger.logDebug('Checking for pubspec.yaml file...');
    Logger.logDebug('Current Directory: $pwd');

    try {
      // Verify if pubspec.yaml exists
      if (!pubspecFile.existsSync()) {
        Logger.logError('pubspec.yaml not found!');
        exit(1); // Exit if file not found
      }

      Logger.logSuccess('pubspec.yaml found.');

      // Backup pubspec.yaml
      Logger.logDebug('Creating backup of pubspec.yaml...');
      pubspecFile.copySync(backupFile.path);
      Logger.logSuccess('Backup created: pubspec.yaml.bak');

      // Read lines from pubspec.yaml
      List<String> lines = pubspecFile.readAsLinesSync();
      List<String> newLines = [];
      bool inFlutterSection = false;
      bool assetsFound = false;

      // Check if assets: section exists and rewrite file
      for (var line in lines) {
        if (line.trim().startsWith('flutter:')) {
          inFlutterSection = true;
        }

        if (inFlutterSection && line.trim().startsWith('assets:')) {
          assetsFound = true;
          continue;
        }
        newLines.add(line);
      }

      if (!assetsFound) {
        // Create a new assets section if not found
        newLines.add('  assets:');
      } else {
        // Remove existing assets paths before adding new ones
        newLines.remove(' assets:');
        newLines.add('  assets:');
        newLines.removeWhere((line) => line.contains('    - assets/'));
      }

      // Add assets paths for icons and images
      final assetDir = Directory('assets');
      if (assetDir.existsSync()) {
        for (var entity in assetDir.listSync()) {
          if (entity is Directory) {
            String featureName = entity.uri.path;
            newLines.add('    - ${featureName}icons/');
            newLines.add('    - ${featureName}images/');
          }
        }
      }

      // Write updated content back to pubspec.yaml
      Logger.logDebug('Updating pubspec.yaml...');
      pubspecFile.writeAsStringSync(newLines.join('\n'));
      Logger.logSuccess('pubspec.yaml updated successfully.');

      _generateDartFiles();
    } catch (e) {
      Logger.logError('An error occurred: $e');
      exit(1);
    }
  }

  // Generate Dart files for each feature's assets
  void _generateDartFiles() async {
    final assetDir = Directory('assets');

    if (!assetDir.existsSync()) {
      Logger.logWarning('assets directory not found!');
      assetDir.createSync();
      Logger.logDebug('Creating assets directory..');
      await Future.delayed(Duration(seconds: 1));
      Logger.logSuccess('assets directory created!');
    }

    for (var featureDir in assetDir.listSync()) {
      if (featureDir is Directory) {
        String featureName = featureDir.path.split('/').last;
        String capitalizedFeatureName = Formatters().capitalize(featureName);
        print(featureName);
        String outputFilePath =
            'lib/features/$featureName/static/assets/${featureName}_screen_assets.dart';

        File outputFile = File(outputFilePath);
        outputFile.createSync(recursive: true);

        // Create content for the Dart file
        StringBuffer fileContent = StringBuffer();
        fileContent.writeln('class ${capitalizedFeatureName}ScreenAssets {');

        // Add icons
        var iconsDir = Directory('${featureDir.path}/icons');
        if (iconsDir.existsSync()) {
          for (var icon in iconsDir.listSync()) {
            if (icon is File) {
              String iconName = icon.uri.pathSegments.last;
              String baseName = iconName.split('.').first;
              String camelCaseName = Formatters().toCamelCase(baseName);
              fileContent.writeln(
                  "  static const String $camelCaseName = 'assets/$featureName/icons/$iconName';");
            }
          }
        }

        // Add images
        var imagesDir = Directory('${featureDir.path}/images');
        if (imagesDir.existsSync()) {
          for (var image in imagesDir.listSync()) {
            if (image is File) {
              String imageName = image.uri.pathSegments.last;
              String baseName = imageName.split('.').first;
              String camelCaseName = Formatters().toCamelCase(baseName);
              fileContent.writeln(
                  "  static const String $camelCaseName = 'assets/$featureName/images/$imageName';");
            }
          }
        }

        fileContent.writeln('}');

        // Write content to file
        outputFile.writeAsStringSync(fileContent.toString());
        Logger.logSuccess('Generated Dart file: $outputFilePath');
      }
    }
  }

  // Main method to start asset generation
  Future<void> onGenerateAssets() async {
    Logger.logDebug('Starting asset generation...');
    _updatePubspecAndGenerateFiles();

    Logger.logSuccess('Asset generation completed successfully.');
  }
}
