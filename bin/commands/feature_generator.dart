import 'dart:io';

import 'package:dcli/dcli.dart';

class FeatureGenerator {
  onGenerateFeature(String? featureName) {
    const featureFolder = 'lib/features';

    if (featureName == null || featureName.isEmpty) {
      print('Usage: dart run -f <feature_name>');
      exit(1);
    }

    final featurePath = '$featureFolder/$featureName';

    final camelCase = toCamelCase(featureName);
    final capitalizedCamelCase = capitalizeFirstLetter(camelCase);

    final viewTemplate = '''
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
import '../../../utils/controllers/feature_controller.dart';

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

    if (!File('pubspec.yaml').existsSync()) {
      print('Please run this from the project level directory.');
      exit(1);
    }

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

    createFeatureStructure(featureName, featurePath, viewTemplate,
        controllerTemplate, cubitTemplate, cubitStateTemplate);

    print('Feature \'$featureName\' has been created successfully.');
  }

  void createFeatureStructure(
      String featureName,
      String featurePath,
      String viewTemplate,
      String controllerTemplate,
      String cubitTemplate,
      String cubitStateTemplate) {
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
    ];

    for (var dir in directories) {
      Directory(dir).createSync(recursive: true);
    }

    writeFile('$featurePath/views/${featureName}_screen.dart', viewTemplate);
    writeFile('$featurePath/controllers/${featureName}_screen_controller.dart',
        controllerTemplate);
    writeFile(
        '$featurePath/logic/${featureName}_cubit/${featureName}_screen_cubit.dart',
        cubitTemplate);
    writeFile(
        '$featurePath/logic/${featureName}_cubit/${featureName}_screen_state.dart',
        cubitStateTemplate);
  }

  void writeFile(String filePath, String content) {
    File(filePath).writeAsStringSync(content);
  }

  String toCamelCase(String string) {
    final words =
        string.split(RegExp(r'[_\s-]')).map((w) => w.toLowerCase()).toList();
    if (words.isEmpty) return '';
    return words[0] + words.skip(1).map(capitalizeFirstLetter).join();
  }

  String capitalizeFirstLetter(String string) {
    return string.isEmpty
        ? string
        : string[0].toUpperCase() + string.substring(1);
  }
}
