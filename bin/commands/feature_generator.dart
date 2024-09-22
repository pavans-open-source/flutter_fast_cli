import 'dart:io';

import 'package:dcli/dcli.dart';
import '../utils/formatters.dart';

class FeatureGenerator {
  final featureFolder = 'lib/features';
  feturePath(String? featureName) => '$featureFolder/$featureName';

  onGenerateFeature(String? featureName) {
    _checkPubspecInCurrDir();
    _validateFeatureName(featureName);
    _checkFeatureExists(featureName);
    _createAFeatureWithContents(featureName);
    _createRoute(
      featureName,
      featureFolder,
    );
  }

  _validateFeatureName(String? featureName) {
    if (featureName == null || featureName.isEmpty) {
      print('Usage: dart run -f <feature_name>');
      exit(1);
    }
  }

  _checkPubspecInCurrDir() {
    if (!File('pubspec.yaml').existsSync()) {
      print('Please run this from the project level directory.');
      exit(1);
    }
  }

  _checkFeatureExists(String? featureName) {
    final featurePath = '$featureFolder/$featureName';
    if (Directory(featurePath).existsSync()) {
      final choice = ask(
          'The feature \'$featureName\' already exists. Do you want to override it? (y/n): ');
      if (choice.toLowerCase() != 'y') {
        print('Operation cancelled.');
        exit(1);
      } else {
        print('Overriding the existing feature...');
      }
    }
  }

  _createAFeatureWithContents(String? featureName) {
    final camelCase = Formatters().toCamelCase(featureName!);
    final capitalizedCamelCase = Formatters().capitalize(camelCase);

    final String viewTemplate = '''
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

    final controllerTemplate = '''
import '../../../utils/global_controller/feature_controller.dart';

class ${capitalizedCamelCase}ScreenController extends FeatureController {
  @override
  void init() {}

  @override
  void dispose() {}
}
''';

    final cubitTemplate = '''
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part '${camelCase}_screen_state.dart';

class ${capitalizedCamelCase}ScreenCubit extends Cubit<${capitalizedCamelCase}ScreenState> {
  ${capitalizedCamelCase}ScreenCubit() : super(${capitalizedCamelCase}ScreenInitial());
}
''';

    final cubitStateTemplate = '''
part of '${camelCase}_screen_cubit.dart';

@immutable
sealed class ${capitalizedCamelCase}ScreenState {}

final class ${capitalizedCamelCase}ScreenInitial extends ${capitalizedCamelCase}ScreenState {}
''';

    final repositoryTemplate = '''
class ${capitalizedCamelCase}Repository {

}
''';

    _writeContentToFiles(
      featureName,
      feturePath(featureName),
      viewTemplate,
      controllerTemplate,
      cubitTemplate,
      cubitStateTemplate,
      repositoryTemplate,
    );

    print('Feature \'$featureName\' has been created successfully.');
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
      '$featurePath/logic',
      '$featurePath/logic/${featureName}_cubit',
      '$featurePath/static',
      '$featurePath/static/assets',
      'assets/$featureName',
      'assets/$featureName/images',
      'assets/$featureName/icons',
      '$featurePath/static/network',
      '$featurePath/static/models',
      '$featurePath/repository'
    ];

    for (var dir in directories) {
      Directory(dir).createSync(recursive: true);
    }

    _writeFile(
      '$featurePath/views/${featureName}_screen.dart',
      viewTemplate,
    );
    _writeFile(
      '$featurePath/controllers/${featureName}_screen_controller.dart',
      controllerTemplate,
    );
    _writeFile(
      '$featurePath/logic/${featureName}_cubit/${featureName}_screen_cubit.dart',
      cubitTemplate,
    );
    _writeFile(
      '$featurePath/logic/${featureName}_cubit/${featureName}_screen_state.dart',
      cubitStateTemplate,
    );

    _writeFile(
      '$featurePath/repository/${featureName}_repository.dart',
      repositoryTemplate,
    );
  }

  void _writeFile(String filePath, String content) {
    File(filePath).writeAsStringSync(content);
  }

  void _createRoute(
    String? featureName,
    String featurePath,
  ) {
    final routers = 'lib/routes/router.dart';
    final routes = 'lib/routes/routes.dart';

    if (!File(routers).existsSync()) {
      File(routers).createSync(recursive: true);
    }

    if (!File(routes).existsSync()) {
      File(routes).createSync(recursive: true);
    }

    // Add to routes
    final routesContent = File(routes).readAsStringSync();

    routesContent.replaceFirst('class Routes {',
        'class Routes {\n  static const String ${Formatters().toCamelCase(featureName!)} = r\'${'/featureName'};');

    File(routes).writeAsStringSync(routesContent);

    // Add to router
    final routerContent = File(routes).readAsStringSync();
    routerContent.replaceFirst('import',
        'import $featurePath/$featureName/views/${featureName}_screen.dart;/n import ');
    routerContent.replaceFirst('return <RouteBase>[', '''return <RouteBase>[
      route(
        name: Routes.${Formatters().toCamelCase(featureName)},
        builder: (context, state) => routeChild(
          context,
          state,
          child: ${Formatters().capitalize(Formatters().toCamelCase(featureName))}Screen,
        ),
      ),''');
  }
}
