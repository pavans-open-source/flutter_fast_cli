import 'dart:io';

import '../logger/logger.dart';

class InitializeFast {
  initializeFastStructure() {
    _createFeatureFolder();
    _createLibraryFolder();
    _initPubscpecFile();
    _initUtilsFolder();
    _initRoutesFolder();
    _initFlavors();
    _initMain();
  }

  _createFeatureFolder() {
    try {
      final featureDir = Directory('lib/feature');
      featureDir.createSync();
    } catch (e) {
      Logger.logError(e.toString());
    }
  }

  _createLibraryFolder() {
    try {
      final librariesDir = Directory('lib/libraries');
      librariesDir.createSync();
    } catch (e) {
      Logger.logError(e.toString());
    }
  }

  _initPubscpecFile() {
    try {
      final pubSpecFile = File('pubspec.yaml');
      final pubSpecBkpFile = File('pubspec.bak.yaml');

      if (!pubSpecFile.existsSync()) {
        Logger.logError('Please run in a flutter directory');
        exit(0);
      }

      Logger.logDebug('Creating backup of pubspec.yaml...');
      pubSpecFile.copySync(pubSpecBkpFile.path);
      Logger.logSuccess('Backup created: pubspec.yaml.bak');

      pubSpecFile.writeAsString(_pubspecYaml);
    } catch (e) {
      Logger.logError(e.toString());
    }
  }

  _initUtilsFolder() {
    final utilsDir = Directory('lib/utils');
    utilsDir.createSync();

    final commonWidgetsDir = Directory('lib/utils/common_widgets');
    final globalControllersDir = Directory('lib/utils/global_controller');
    final globalStaticDir = Directory('lib/utils/global_controller');
    final commonFuncDir = Directory('lib/utils/common_functions');
    final staticDir = Directory('lib/utils/static');

    commonFuncDir.createSync(recursive: true);
    globalStaticDir.createSync(recursive: true);
    globalControllersDir.create(recursive: true);
    commonWidgetsDir.createSync(recursive: true);
    staticDir.createSync(recursive: true);

    // Common widgets
    final appImgDart = File('${commonWidgetsDir.path}/app_image.dart');
    final errorWidgetDart = File('${commonWidgetsDir.path}/error_widget.dart');
    final screenConstDart =
        File('${commonWidgetsDir.path}/screen_constants.dart');

    appImgDart.writeAsStringSync(_appImageDart);
    errorWidgetDart.writeAsStringSync(_errorWidgetDart);
    screenConstDart.writeAsStringSync(_screenConst);

    // Common functions
    final dateFormatterDart = File('${commonFuncDir.path}/date_formatter.dart');
    final stringExtensionDart =
        File('${commonFuncDir.path}/string_extensions.dart');

    dateFormatterDart.writeAsStringSync(_dateFormatterDart);
    stringExtensionDart.writeAsStringSync(_stringExtensionsDart);

    // Global Controllers
    final featureControllerDart =
        File('${globalControllersDir.path}/feature_controller.dart');
    featureControllerDart.writeAsStringSync(_featureControllerDart);

    // Static
  }

  void _initFlavors() {}

  void _initRoutesFolder() {
    final routesDir = Directory('lib/routes');
    routesDir.createSync();

    final routesDart = File('lib/routes/routes.dart');
    final routerDart = File('lib/routes/router.dart');

    routesDart.create();
    routerDart.create();
  }

  void _initMain() {
    final mainDart = File('lib/main.dart');
    mainDart.createSync();

    mainDart.writeAsStringSync(_mainDart);
  }
}

final _pubspecYaml = '''
name: starter_template
description: "A new Flutter project."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.4.4 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.6
  flutter_flavorizr: ^2.2.3
  get_cubit: ^1.1.0
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  flutter_svg: ^2.0.10+1
  intl: ^0.19.0
  validators: ^3.0.0
  logger: ^2.4.0
  path_provider: ^2.1.3
  encrypt: ^5.0.3
  http: ^1.2.2
  api_cache_manager: ^1.0.2
  http_requester: ^0.0.4
  cached_network_image: ^3.4.1
  lottie: ^3.1.2
  common_utilities_flutter: ^0.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
''';

final _errorWidgetDart = '''
import 'package:flutter/material.dart';

class ErrorWidget extends StatefulWidget {
  ErrorWidget({
    super.key,
    this.error,
    this.head,
    required this.onTap,
  });

  Widget? head;
  String? error;
  Function() onTap;

  @override
  State<ErrorWidget> createState() => _ErrorWidgetState();

  factory ErrorWidget.mini({
    required Function() onTap,
    required String? errorString,
    Widget? head,
  }) {
    return ErrorWidget(
      head: null,
      onTap: onTap,
      error: errorString,
    );
  }

  factory ErrorWidget.regular({
    required Function() onTap,
    required String? errorString,
    Widget? head,
  }) {
    return ErrorWidget(
      head: head ?? const SizedBox.shrink(),
      onTap: onTap,
      error: errorString,
    );
  }
}

class _ErrorWidgetState extends State<ErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.head != null)
          Column(
            children: [
              widget.head!,
              const SizedBox(
                height: 16,
              ),
              Text(
                widget.error ?? '',
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
      ],
    );
  }
}

''';

final _screenConst = '''
import 'package:flutter/material.dart';

Size? screenSize;
double defaultScreenWidth = 390.0;
double defaultScreenHeight = 844.0;
double screenWidth = defaultScreenWidth;
double screenHeight = defaultScreenHeight;

//break point for responsive
double widthBP = 700.0;

class ScreenConstant {
  static void setDefaultSize(context) {
    screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize?.width ?? 0;
    screenHeight = screenSize?.height ?? 0;
  }

  static void setScreenAwareConstant(context) {
    setDefaultSize(context);
  }
}
''';

final _dateFormatterDart = '''
import 'package:intl/intl.dart';

class DateFormatter {
  final DateTime dateTime;

  DateFormatter(this.dateTime);

  // Format as 'yyyy-MM-dd'
  String toYearMonthDay() {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  // Format as 'dd-MM-yyyy'
  String toDayMonthYear() {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  // Format as 'MMMM dd, yyyy' (e.g., 'July 24, 2024')
  String toFullMonthDayYear() {
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  }

  // Format as 'MM/dd/yyyy'
  String toMonthDayYear() {
    return DateFormat('MM/dd/yyyy').format(dateTime);
  }

  // Format as 'yyyy/MM/dd HH:mm' (24-hour format)
  String toYearMonthDayHourMinute() {
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

  // Format as 'MMM d, yyyy' (e.g., 'Jul 24, 2024')
  String toShortMonthDayYear() {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  // Format as 'yyyy-MM-ddTHH:mm:ss' (ISO 8601)
  String toIso8601() {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(dateTime);
  }

  // Format as 'EEEE, MMMM d, yyyy' (e.g., 'Wednesday, July 24, 2024')
  String toWeekdayMonthDayYear() {
    return DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
  }

  // Format as 'HH:mm:ss' (24-hour format)
  String toTime24Hour() {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  // Format as 'hh:mm a' (12-hour format with AM/PM)
  String toTime12Hour() {
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Custom format
  String toCustomFormat(String pattern) {
    return DateFormat(pattern).format(dateTime);
  }
}
''';

final _appImageDart = '''

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StringToImage extends StatelessWidget {
  final String? imagePath;
  final Uint8List? memoryImage;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const StringToImage({
    super.key,
    this.imagePath,
    this.memoryImage,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  bool _isNetworkUrl(String? path) =>
      path?.startsWith(RegExp(r'http(s)?://')) ?? false;
  bool _isSvg(String? path) => path?.endsWith('.svg') ?? false;

  @override
  Widget build(BuildContext context) {
    if (memoryImage != null) {
      return Image.memory(
        memoryImage!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ?? const Icon(Icons.error),
      );
    }

    if (imagePath == null) {
      return errorWidget ?? const Icon(Icons.error);
    }

    if (_isNetworkUrl(imagePath)) {
      return _isSvg(imagePath)
          ? SvgPicture.network(
              imagePath!,
              width: width,
              height: height,
              fit: fit ?? BoxFit.contain,
              placeholderBuilder: (_) =>
                  placeholder ?? const CircularProgressIndicator(),
            )
          : Image.network(
              imagePath!,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return placeholder ??
                    Center(
                        child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ));
              },
              errorBuilder: (_, __, ___) =>
                  errorWidget ?? const Icon(Icons.error),
            );
    } else {
      return _isSvg(imagePath)
          ? SvgPicture.asset(
              imagePath!,
              width: width,
              height: height,
              fit: fit ?? BoxFit.contain,
              placeholderBuilder: (_) =>
                  placeholder ?? const CircularProgressIndicator(),
            )
          : Image.asset(
              imagePath!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) =>
                  errorWidget ?? const Icon(Icons.error),
            );
    }
  }
}

''';

final _stringExtensionsDart = r'''
import 'package:validators/validators.dart' as validators;
import 'dart:convert';

extension StringUtils on String {
  // Checks if the string is a valid email address
  bool get isValidEmail {
    return validators.isEmail(this);
  }

  // Checks if the string is a valid URL
  bool get isValidUrl {
    return validators.isURL(this);
  }

  // Checks if the string is a valid phone number (basic validation)
  bool get isValidPhoneNumber {
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return regex.hasMatch(this);
  }

  // Checks if the string is a valid credit card number
  bool get isValidCreditCard {
    return validators.isCreditCard(this);
  }

  // Checks if the string is a valid IPv4 address
  bool get isValidIPv4 {
    final regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return regex.hasMatch(this);
  }


  // Checks if the string is a valid UUID (version 4)
  bool get isValidUUID {
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(this);
  }

  // Checks if the string is a valid JSON
  bool get isValidJson {
    try {
      final json = jsonDecode(this);
      return json is Map || json is List;
    } catch (e) {
      return false;
    }
  }

  // Checks if the string contains only alphabets (letters)
  bool get isAlphabet {
    final regex = RegExp(r'^[a-zA-Z]+$');
    return regex.hasMatch(this);
  }

  // Checks if the string contains only digits
  bool get isDigits {
    final regex = RegExp(r'^\d+$');
    return regex.hasMatch(this);
  }

  // Checks if the string is a valid password (at least 8 characters, with at least one letter and one number)
  bool get isValidPassword {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return regex.hasMatch(this);
  }

  // Capitalizes the first letter of each word
  String capitalizeEachWord() {
    return split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Capitalizes the first letter of the string
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  // Converts the string to title case
  String toTitleCase() {
    return split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Reverses the characters in the string
  String reverse() {
    return split('').reversed.join('');
  }

  // Checks if the string is a palindrome
  bool get isPalindrome {
    String reversed = reverse();
    return this == reversed;
  }

  // Removes all whitespace from the string
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  // Truncates the string to a specified length and appends an ellipsis if necessary
  String truncate(int length, [String ellipsis = '...']) {
    if (this.length <= length) return this;
    return '${substring(0, length)}$ellipsis';
  }

  // Converts the string to snake_case
  String toSnakeCase() {
    return replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1_$2')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  // Converts the string to kebab-case
  String toKebabCase() {
    return replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1-$2')
        .replaceAll(RegExp(r'\s+'), '-')
        .toLowerCase();
  }

  // Checks if the string contains only letters and numbers
  bool get containsOnlyLettersAndNumbers {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(this);
  }

  // Checks if the string contains any special characters
  bool get containsSpecialCharacters {
    final regex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return regex.hasMatch(this);
  }

  // Returns a list of words from the string
  List<String> getWords() {
    return split(RegExp(r'\s+'));
  }

  // Pads the string with a specified character from the left to a certain length
  String padLeftWithChar(int length, [String padChar = ' ']) {
    return padLeft(length, padChar);
  }

  // Pads the string with a specified character from the right to a certain length
  String padRightWithChar(int length, [String padChar = ' ']) {
    return padRight(length, padChar);
  }
}
''';

final _featureControllerDart = '''
abstract class FeatureController {
  void init();
  void dispose();
}
''';

final _mainDart = '''
import 'package:flutter/material.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(),
    );
  }
}
''';
