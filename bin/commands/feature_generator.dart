import 'dart:io';

import 'package:dcli/dcli.dart';
import '../utils/formatters.dart';

class FeatureGenerator {
  final featureFolder = 'lib/features';
  feturePath(String? featureName) => '$featureFolder/$featureName';

  /// The function `onGenerateFeature` generates code templates for a new feature in a Flutter project
  /// based on the provided feature name.
  ///
  /// Args:
  ///   featureName (String): The `featureName` parameter is a string that represents the name of the
  /// feature you want to generate. It is used to create the necessary files and folder structure for a
  /// new feature in a Flutter project.
  onGenerateFeature(String? featureName) {
    _checkPubspecInCurrDir();
    _validateFeatureName(featureName);
    _checkFeatureExists(featureName);
    _createAFeatureWithContents(featureName);
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

    _setContentToFiles(
      featureName,
      feturePath(featureName),
      viewTemplate,
      controllerTemplate,
      cubitTemplate,
      cubitStateTemplate,
    );

    print('Feature \'$featureName\' has been created successfully.');
  }

  /// The `createFeatureStructure` function in Dart creates a directory structure for a new feature in a
  /// Flutter project and generates necessary files based on provided templates.
  ///
  /// Args:
  ///   featureName (String): The `featureName` parameter is the name of the feature or module that you
  /// are creating. It will be used to generate various files and directories with this name as part of
  /// their naming convention.
  ///   featurePath (String): The `featurePath` parameter is the base path where the feature structure
  /// will be created. It is used to define the root directory for the feature and its subdirectories
  /// where the generated files will be placed.
  ///   viewTemplate (String): The `viewTemplate` parameter in the `createFeatureStructure` function is a
  /// string that represents the template for the view file of a feature in a Flutter project. This
  /// template likely contains the structure and layout of the feature's screen, including widgets,
  /// layout, and any other UI elements specific to that
  ///   controllerTemplate (String): The `controllerTemplate` parameter in the `createFeatureStructure`
  /// function is a string that represents the template for the controller file of a feature in a Flutter
  /// project. This template likely contains the code structure and logic for the controller that will be
  /// generated for the feature. When the `createFeatureStructure`
  ///   cubitTemplate (String): The `cubitTemplate` parameter in the `createFeatureStructure` function is
  /// a string that represents the template for the Cubit class related to a specific feature in a Flutter
  /// application. This template typically includes the structure and initial implementation of the Cubit
  /// class, which is responsible for managing the state of
  ///   cubitStateTemplate (String): The `cubitStateTemplate` parameter in the `createFeatureStructure`
  /// function is a String that represents the template for the state class of a Cubit in a Flutter
  /// feature. This template is used to generate the code for the state class of the Cubit associated with
  /// a specific feature in the Flutter
  void _setContentToFiles(
    String featureName,
    String featurePath,
    String viewTemplate,
    String controllerTemplate,
    String cubitTemplate,
    String cubitStateTemplate,
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
  }

  /// The `writeFile` function in Dart writes the specified content to a file at the given file path.
  ///
  /// Args:
  ///   filePath (String): The `filePath` parameter is a string that represents the path to the file where
  /// you want to write the content. It should include the file name and its location in the file system.
  ///   content (String): The `content` parameter in the `writeFile` function represents the text or data
  /// that you want to write to the file specified by the `filePath` parameter. It is the actual content
  /// that will be written to the file.
  void _writeFile(String filePath, String content) {
    File(filePath).writeAsStringSync(content);
  }
}
