import 'dart:io';

import 'package:dcli/dcli.dart';

bool pubspecContainsPackage(String package) {
  final pubspecFile = File('$pwd/pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    throw FileSystemException("pubspec.yaml not found");
  }

  final pubspecContent = pubspecFile.readAsLinesSync();

  for (var line in pubspecContent) {
    if (line.trim().startsWith('$package:')) {
      return true;
    }
  }
  return false;
}
