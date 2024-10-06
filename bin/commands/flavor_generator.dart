import 'dart:io';
import 'package:dcli/dcli.dart';
import '../logger/logger.dart';
import '../common/pubspec_package_exist.dart';

class FlavorGenerator {
  void onGenerateFlavors(List<String> flavors) {
    _initializeFlavorPackage();
    _createFlavorizrFile(flavors);
    _runFlavorizr();
    _gitInit(flavors);
    _fix();
  }

  void _fix() {
    Logger.logDebug('Cleaning up...');
    Process.runSync('dart', ['fix', '--apply']);
    Process.runSync('dart', ['format', '.']);
  }

  void _gitInit(List<String> flavors) {
    final gitDir = Directory('.git');

    if (gitDir.existsSync()) {
      print('Git repository already exists.');
    } else {
      // Initialize Git repository
      try {
        final initResult = Process.runSync('git', ['init']);
        print(initResult.stdout);
        print('Git repository initialized.');
      } catch (e) {
        print('Failed to initialize Git repository: $e');
        return;
      }
    }

    // Create branches for each flavor
    for (String flavor in flavors) {
      if (_branchExists(flavor)) {
        print('Branch $flavor already exists. Skipping creation.');
        continue;
      }

      try {
        final createBranchResult =
            Process.runSync('git', ['checkout', '-b', flavor]);
        print(createBranchResult.stdout);
        print('Branch $flavor created.');
      } catch (e) {
        print('Failed to create branch $flavor: $e');
      }
    }

    // Optionally switch back to the main branch
    try {
      final checkoutMainResult = Process.runSync('git', ['checkout', 'main']);
      print(checkoutMainResult.stdout);
      print('Switched to main branch.');
    } catch (e) {
      print('Failed to switch to main branch: $e');
    }
  }

  bool _branchExists(String branchName) {
    try {
      final result = Process.runSync('git', ['branch']);
      final branches = result.stdout.toString().split('\n');
      return branches.any((branch) => branch.trim() == branchName);
    } catch (e) {
      print('Failed to check if branch $branchName exists: $e');
      return false;
    }
  }

  _runFlavorizr() {
    Logger.logWarning(
        '\nPlease wait while flutter_fast is creating flavors...');
    try {
      final result = Process.runSync(
        'dart',
        ['run', 'flutter_flavorizr'],
        runInShell: false,
      );

      if (result.exitCode == 0) {
        Logger.logSuccess('\nYayy... flutter_fast has created flavors\n');
      } else {
        Logger.logWarning('Error: ${result.stderr}');
      }
    } catch (e) {
      Logger.logWarning(e.toString());
    }
  }

  _initializeFlavorPackage() {
    try {
      final packageExists = pubspecContainsPackage('flutter_flavorizr');

      if (packageExists) return;

      'flutter pub add flutter_flavorizr'.start(
        terminal: true,
        runInShell: true,
      );
    } catch (e) {
      Logger.logWarning(e.toString());
    }
  }

  // String? _extractOrgName() {
  //   final androidManifest = File('android/app/src/main/AndroidManifest.xml');
  //   String? orgName;

  //   if (androidManifest.existsSync()) {
  //     final content = androidManifest.readAsStringSync();

  //     final packageNameRegExp = RegExp(r'package="([^"]+)"');
  //     final match = packageNameRegExp.firstMatch(content);

  //     if (match != null) {
  //       final packageName = match.group(1);
  //       Logger.logSuccess('Package Name: $packageName');

  //       orgName = packageName?.split('.').take(2).join('.');
  //       Logger.logSuccess('Organization Name: $orgName');
  //     }
  //   } else {
  //     Logger.logError('AndroidManifest.xml not found.');
  //   }

  //   return orgName;
  // }
  String _extractOrgNameFromGradle() {
    final gradleFile = File('android/app/build.gradle');

    if (!gradleFile.existsSync()) {
      print('build.gradle file not found.');
      exit(0);
    }

    final content = gradleFile.readAsStringSync();

    // Regular expression to match applicationId value
    final applicationIdRegExp = RegExp(r'applicationId\s*=\s*"([^"]+)"');
    final match = applicationIdRegExp.firstMatch(content);

    if (match != null) {
      final applicationId = match.group(1);
      print('Application ID: $applicationId');

      // Extract the organization name (assuming it's the first segment of the applicationId)
      final orgName = applicationId?.split('.').take(2).join('.');
      print('Organization Name: $orgName');

      return orgName!;
    } else {
      print('applicationId not found in build.gradle.');
      exit(0);
    }
  }

  void _createFlavorizrFile(List<String> flavors) {
    bool pubspecExists = File('$pwd/pubspec.yaml').existsSync();
    final flavorizrFile = File('$pwd/flavorizr.yaml');
    Logger.logSuccess('Pubspec found: $pubspecExists, ${flavorizrFile.path}');
    final flavorizrContent = StringBuffer();
    String orgName = _extractOrgNameFromGradle();

    if (!pubspecExists) {
      Logger.logError('Please run this command in the root of your project.');
      return;
    }

    if (orgName.isEmpty) {
      Logger.logError('Could not extract organization name.');
      return;
    }

    final baseFlavorizr = '''
flavorizr:
  ide: "vscode"
  app:
    android:
      flavorDimensions: "flavor"
    ios:

flavors:
''';

    // Start building the flavorizr content
    flavorizrContent.writeln(baseFlavorizr);

    for (final flavor in flavors) {
      flavorizrContent.writeln('    $flavor:');
      flavorizrContent.writeln('      app:');
      flavorizrContent.writeln('        name: "$flavor App"');
      flavorizrContent.writeln('      android:');
      flavorizrContent.writeln(
          '        applicationId: "$orgName.${flavor.toLowerCase() == 'uat' ? 'app' : flavor.toLowerCase()}"');
      flavorizrContent.writeln('      ios:');
      flavorizrContent
          .writeln('        bundleId: "$orgName.${flavor.toLowerCase()}"');
      flavorizrContent.writeln('        buildSettings:');
      flavorizrContent.writeln('          DEVELOPMENT_TEAM: YOURDEVTEAMID');
      flavorizrContent.writeln(
          '          PROVISIONING_PROFILE_SPECIFIER: "Dev-ProvisioningProfile"');
    }

    if (flavorizrFile.existsSync()) {
      Logger.logSuccess('flavorizr.yaml file will be overwrited..!');
    }
    flavorizrFile.createSync();
    flavorizrFile.writeAsStringSync(flavorizrContent.toString());
    Logger.logSuccess('flavorizr.yaml file created.');
  }
}
