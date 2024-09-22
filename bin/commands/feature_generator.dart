import 'dart:io';
import 'package:dcli/dcli.dart';
import '../utils/formatters.dart';
import '../logger/logger.dart';

class FeatureGenerator {
  final String featureFolder = 'lib/features';

  String featurePath(String? featureName) => '$featureFolder/$featureName';

  void onGenerateFeature(String? featureName) {
    try {
      Logger.logDebug('\nStarting feature generation for: $featureName\n');
      _checkPubspecInCurrDir();
      _validateFeatureName(featureName);
      _checkFeatureExists(featureName);
      _createFeatureWithContents(featureName);
      _createRoutes(featureName);
      _createRouters(featureName);
      _cleanAndFormat();
      Logger.logSuccess('\nFeature generated successfully: $featureName\n');
    } catch (e) {
      Logger.logError('\nError generating feature: $e\n');
      exit(1);
    }
  }

  void _validateFeatureName(String? featureName) {
    if (featureName == null || featureName.isEmpty) {
      Logger.logError('Feature name is invalid or missing.');
      exit(1);
    }
  }

  void _checkPubspecInCurrDir() {
    if (!File('pubspec.yaml').existsSync()) {
      Logger.logError(
          'pubspec.yaml not found. Please run this from the project directory.');
      exit(1);
    }
  }

  void _checkFeatureExists(String? featureName) {
    final featurePath = this.featurePath(featureName);
    if (Directory(featurePath).existsSync()) {
      final choice = ask(
        'The feature \'$featureName\' already exists. Do you want to override it? (y/n): ',
      );
      if (choice.toLowerCase() != 'y') {
        Logger.logWarning('Operation cancelled.');
        exit(0); // Normal exit as the user cancelled.
      } else {
        Logger.logWarning('Overriding existing feature: $featureName');
      }
    }
  }

  void _createFeatureWithContents(String? featureName) {
    Logger.logDebug('Creating feature contents for $featureName');

    final camelCase = Formatters().toCamelCase(featureName!);
    final capitalizedCamelCase = Formatters().capitalize(camelCase);

    // Templates
    final viewTemplate =
        _createViewTemplate(featureName, camelCase, capitalizedCamelCase);
    final controllerTemplate = _createControllerTemplate(capitalizedCamelCase);
    final cubitTemplate = _createCubitTemplate(camelCase, capitalizedCamelCase);
    final cubitStateTemplate =
        _createCubitStateTemplate(camelCase, capitalizedCamelCase);
    final repositoryTemplate = _createRepositoryTemplate(capitalizedCamelCase);

    // Write content to files
    _writeContentToFiles(
      featureName,
      featurePath(featureName),
      viewTemplate,
      controllerTemplate,
      cubitTemplate,
      cubitStateTemplate,
      repositoryTemplate,
    );

    Logger.logSuccess('Feature contents created successfully for $featureName');
  }

  void _writeContentToFiles(
    String featureName,
    String featurePath,
    String viewTemplate,
    String controllerTemplate,
    String cubitTemplate,
    String cubitStateTemplate,
    String repositoryTemplate,
  ) {
    final directories = [
      '$featurePath/views',
      '$featurePath/controllers',
      '$featurePath/logic/${featureName}_cubit',
      '$featurePath/static/assets',
      'assets/$featureName/images',
      'assets/$featureName/icons',
      '$featurePath/static/network',
      '$featurePath/static/models',
      '$featurePath/repository',
    ];

    for (var dir in directories) {
      Logger.logDebug('Creating directory: $dir');
      Directory(dir).createSync(recursive: true);
    }

    _writeFile('$featurePath/views/${featureName}_screen.dart', viewTemplate);
    _writeFile('$featurePath/controllers/${featureName}_screen_controller.dart',
        controllerTemplate);
    _writeFile(
        '$featurePath/logic/${featureName}_cubit/${featureName}_screen_cubit.dart',
        cubitTemplate);
    _writeFile(
        '$featurePath/logic/${featureName}_cubit/${featureName}_screen_state.dart',
        cubitStateTemplate);
    _writeFile('$featurePath/repository/${featureName}_repository.dart',
        repositoryTemplate);
  }

  void _writeFile(String filePath, String content) {
    try {
      Logger.logDebug('Writing content to $filePath');
      File(filePath).writeAsStringSync(content);
    } catch (e) {
      Logger.logError('Failed to write to $filePath: $e');
    }
  }

  Future<void> _createRouters(String? featureName) async {
    final routers = 'lib/routes/router.dart';
    await _checkAndCreateFile(routers);

    final routeVar =
        'AppRoutes.${Formatters().toCamelCase(featureName!)}Screen';
    final importVar =
        'import \'../features/$featureName/views/${featureName}_screen.dart\';';

    String routersContent = await File(routers).readAsString();

    if (!routersContent.contains(importVar)) {
      routersContent = routersContent.replaceFirst(
        'class AppRouter {',
        '$importVar\nclass AppRouter {',
      );
    }

    if (!routersContent.contains(routeVar)) {
      routersContent = routersContent.replaceFirst(
        ' return <RouteBase>[',
        '''return <RouteBase>[
          route(
            name: AppRoutes.${Formatters().toCamelCase(featureName)}Screen,
            builder: (context, state) => const ${Formatters().capitalize(Formatters().toCamelCase(featureName))}Screen(),
          ),\n''',
      );
    }

    await File(routers).writeAsString(routersContent);
  }

  Future<void> _createRoutes(String? featureName) async {
    final routes = 'lib/routes/routes.dart';
    await _checkAndCreateFile(routes);

    String variable =
        'static const String ${Formatters().toCamelCase(featureName!)}Screen = \'/$featureName\';';

    String routesContent = await File(routes).readAsString();

    if (!routesContent.contains(variable)) {
      routesContent = routesContent.replaceFirst(
        'class AppRoutes {',
        'class AppRoutes {\n $variable\n',
      );
    }

    await File(routes).writeAsString(routesContent);
  }

  Future<void> _checkAndCreateFile(String filePath) async {
    if (!File(filePath).existsSync()) {
      Logger.logDebug('Creating file: $filePath');
      await File(filePath).create(recursive: true);
    }
  }

  void _cleanAndFormat() {
    Logger.logWarning('Running dart fix and formatting...');
    Process.runSync('dart', ['fix', '--apply']);
    Process.runSync('dart', ['format', 'lib']);
    Logger.logSuccess('Codebase formatted and fixed.');
    exit(0);
  }
}

// Template generators
String _createViewTemplate(
    String featureName, String camelCase, String capitalizedCamelCase) {
  return '''
import 'package:flutter/material.dart';
import '../controllers/${featureName}_screen_controller.dart';

class ${capitalizedCamelCase}Screen extends StatefulWidget {
  const ${capitalizedCamelCase}Screen({super.key});

  @override
  State<${capitalizedCamelCase}Screen> createState() => _${capitalizedCamelCase}ScreenState();
}

class _${capitalizedCamelCase}ScreenState extends State<${capitalizedCamelCase}Screen> {
  ${capitalizedCamelCase}ScreenController ${camelCase}ScreenController = ${capitalizedCamelCase}ScreenController();

  @override
  void initState() {
    ${camelCase}ScreenController.init();
    super.initState();
  }

  @override
  void dispose() {
    ${camelCase}ScreenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
''';
}

String _createControllerTemplate(String capitalizedCamelCase) {
  return '''
import '../../../utils/global_controller/feature_controller.dart';

class ${capitalizedCamelCase}ScreenController extends FeatureController {
  @override
  void init() {}

  @override
  void dispose() {}
}
''';
}

String _createCubitTemplate(String camelCase, String capitalizedCamelCase) {
  return '''
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part '${camelCase}_screen_state.dart';

class ${capitalizedCamelCase}ScreenCubit extends Cubit<${capitalizedCamelCase}ScreenState> {
  ${capitalizedCamelCase}ScreenCubit() : super(${capitalizedCamelCase}ScreenInitial());
}
''';
}

String _createCubitStateTemplate(
    String camelCase, String capitalizedCamelCase) {
  return '''
part of '${camelCase}_screen_cubit.dart';

@immutable
sealed class ${capitalizedCamelCase}ScreenState {}

final class ${capitalizedCamelCase}ScreenInitial extends ${capitalizedCamelCase}ScreenState {}
''';
}

String _createRepositoryTemplate(String capitalizedCamelCase) {
  return '''
class ${capitalizedCamelCase}Repository {

}
''';
}
