import 'dart:convert';
import 'dart:io';
import 'package:dcli/dcli.dart';
import '../logger/logger.dart';

class CicdGenerator {
  void onCicdGenerate(String cicdUsing) {
    Logger.logDebug('Starting CI/CD generation for: $cicdUsing');
    switch (cicdUsing) {
      case 'github':
        _githubCicd();
        break;
      case 'gitlab':
        _gitlabCicd();
        break;
      default:
        Logger.logWarning(
            'Please use flutter_fast --cicd [action]   :   action - github/gitlab');
        exit(0);
    }
    Logger.logDebug('Cleaning up...');
    _fix();
  }

  void _fix() {
    Logger.logDebug('Cleaning up...');
    Process.runSync('dart', ['fix', '--apply']);
    Process.runSync('dart', ['format', '.']);
  }

  void _githubCicd() {
    Logger.logDebug('Generating GitHub CI/CD configuration...');
    _cicdPrerequisite();
    _createGithubAction();
    Logger.logSuccess('GitHub CI/CD configuration generated successfully.');
  }

  void _gitlabCicd() {
    Logger.logDebug('Generating GitLab CI/CD configuration...');
    _cicdPrerequisite();
    _createGitlabAction();
    Logger.logSuccess('GitLab CI/CD configuration generated successfully.');
  }

  void _cicdPrerequisite() {
    Logger.logDebug('Performing CI/CD prerequisites...');
    _initiateFastlane();
    _createAndroidFastlane();
    _createIosFastlane();
    Logger.logSuccess('CI/CD prerequisites completed.');
  }

  void _createGitlabAction() {
    final gitlabAction = File('.gitlab-ci.yml');

    if (!gitlabAction.existsSync()) {
      gitlabAction.createSync();
      Logger.logDebug('Created .gitlab-ci.yml file.');
    } else {
      Logger.logDebug('.gitlab-ci.yml file already exists.');
    }

    gitlabAction.writeAsStringSync(
      _gitlabActionFile.toString(),
      mode: FileMode.write,
      encoding: utf8,
    );
    Logger.logSuccess('GitLab CI/CD configuration written successfully.');
  }

  void _createAndroidFastlane() {
    // final fastlaneInitProcess = 'fastlane init'.start(
    //   terminal: true,
    //   runInShell: true,
    //   workingDirectory: '$pwd/android',
    // );
    final fastlaneInitProcess = Process.runSync(
      'fastlane',
      ['--init'],
      workingDirectory: '$pwd/android',
    );

    // if (fastlaneInitProcess.exitCode != 0) {
    //   Logger.logError(
    //       'Failed to initialize Fastlane in the Android directory.');
    //   Logger.logError('STDOUT: ${fastlaneInitProcess.stdout}');
    //   exit(1);
    // }

    touch('$pwd/android/fastlane/Fastfile');

    final fastfile = File('$pwd/android/fastlane/Fastfile');
    if (!fastfile.existsSync()) {
      fastfile.createSync();
    }

    fastfile.writeAsStringSync(
      _androidFastfile.toString(),
    );

    Logger.logSuccess(
        'Fastlane initialized and Fastfile created in Android directory.');
    exit(0);
  }

  void _createIosFastlane() {
    'cd ios'.run;
    final fastlaneInitProcess = 'fastlane init'.start(
      terminal: true,
      runInShell: true,
    );
    // if (fastlaneInitProcess.exitCode != 0) {
    //   Logger.logError('Failed to initialize fastlane in iOS directory.');
    //   exit(1);
    // }

    touch('$pwd/ios/fastlane/Fastfile');

    final fastfile = File('fastlane/Fastfile');
    if (!fastfile.existsSync()) {
      fastfile.createSync();
      Logger.logDebug('Created Fastfile in iOS directory.');
    }

    fastfile.writeAsStringSync(
      _iosFastlane.toString(),
      mode: FileMode.write,
      encoding: utf8,
    );
    Logger.logSuccess('iOS Fastfile written successfully.');
  }

  void _createGithubAction() {
    final githubActionFile = File('.github/workflows/flutter.yml');

    if (!githubActionFile.existsSync()) {
      githubActionFile.createSync(recursive: true);
      Logger.logDebug('Created .github/workflows/flutter.yml file.');
    } else {
      Logger.logDebug('.github/workflows/flutter.yml file already exists.');
    }

    githubActionFile.writeAsStringSync(
      githubAction.toString(),
      mode: FileMode.write,
      encoding: utf8,
    );
    Logger.logSuccess('GitHub Actions configuration written successfully.');
  }

  void _initiateFastlane() {
    Logger.logDebug('Checking Fastlane installation...');

    final fastlaneProcess = Process.runSync('fastlane', ['--version']);
    // final fastlaneProcess = 'fastlane --version'.start(
    //   terminal: true,
    //   runInShell: true,
    // );
    if (fastlaneProcess.exitCode != 0) {
      Logger.logDebug('Fastlane not installed. Installing Fastlane...');
      _installFastlane();
    } else {
      Logger.logDebug('Fastlane is already installed.');
    }
  }

  void _installFastlane() {
    Logger.logDebug('Checking Ruby installation...');
    final rubyProcess = 'ruby --version'.start(
      terminal: true,
      runInShell: true,
    );

    if (rubyProcess.exitCode != 0) {
      Logger.logDebug('Ruby not installed. Installing Ruby...');
      _installRuby();
    }

    Logger.logDebug('Installing Fastlane...');
    final process = 'sudo gem install fastlane'.start(
      terminal: true,
      runInShell: true,
    );
    if (process.exitCode != 0) {
      Logger.logError('Error while installing Fastlane.');
      exit(1);
    }
    Logger.logSuccess('Fastlane installed successfully.');
  }

  void _installRuby() {
    Logger.logDebug('Installing Ruby...');
    'brew install ruby'.start(
      terminal: true,
      runInShell: true,
    );
    Logger.logSuccess('Ruby installed successfully.');
  }
}

StringBuffer _gitlabActionFile = StringBuffer(r'''
stages:
  - code_quality
  - test
  - build
  - deploy

variables:
  KEYSTORE_FILE: "$CI_PROJECT_DIR/.secrets/upload-key.jks"
  KEYSTORE_PASSWORD: "your_keystore_password"
  KEY_ALIAS: "your_key_alias"
  KEY_PASSWORD: "your_key_password"
  GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: "$CI_PROJECT_DIR/google_play_service_account.json"
  SONAR_SCANNER_VERSION: "4.7.0.2747"
  SONAR_SCANNER_HOME: "$CI_PROJECT_DIR/.sonar-scanner"

# SonarQube code quality analysis
code_quality:
  stage: code_quality
  image: "sonarsource/sonar-scanner-cli:${SONAR_SCANNER_VERSION}"
  script:
    - sonar-scanner -Dsonar.projectKey=my_project -Dsonar.sources=lib -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_LOGIN
  allow_failure: true
  only:
    - dev
    - uat
    - prod

test:
  stage: test
  image: "ghcr.io/cirruslabs/flutter:3.10.3"
  before_script:
    - flutter pub global activate junitreport
    - export PATH="$PATH:$HOME/.pub-cache/bin"
  script:
    - flutter pub get
    - flutter test --machine --coverage --flavor $CI_COMMIT_REF_NAME | tojunit -o report-$CI_COMMIT_REF_NAME.xml
    - lcov --summary coverage/lcov.info
    - genhtml coverage/lcov.info --output=coverage/$CI_COMMIT_REF_NAME
  coverage: '/lines\.*: \d+\.\d+\%/'
  artifacts:
    name: coverage_$CI_COMMIT_REF_NAME
    paths:
      - $CI_PROJECT_DIR/coverage/$CI_COMMIT_REF_NAME
    reports:
      junit: report-$CI_COMMIT_REF_NAME.xml
  only:
    - dev
    - uat
    - prod

build:
  stage: build
  image: "alpine:latest"
  before_script:
    - apk add --no-cache ruby ruby-dev openjdk11 bash
    - gem install fastlane
    - curl -o $KEYSTORE_FILE ${CI_JOB_TOKEN}@${CI_SERVER_URL}/api/v4/projects/${CI_PROJECT_ID}/jobs/artifacts/${CI_COMMIT_REF_NAME}/raw/android/app/my-upload-key.jks?job=build
    - curl -o $GOOGLE_PLAY_SERVICE_ACCOUNT_JSON ${CI_JOB_TOKEN}@${CI_SERVER_URL}/api/v4/projects/${CI_PROJECT_ID}/jobs/artifacts/${CI_COMMIT_REF_NAME}/raw/google_play_service_account.json?job=build
  script:
    - |
      # Build Android
      flutter pub get
      flutter build appbundle --flavor $CI_COMMIT_REF_NAME --release
    - |
      # Build iOS
      fastlane ios build --env $CI_COMMIT_REF_NAME
  artifacts:
    paths:
      - build/app/outputs/bundle/${CI_COMMIT_REF_NAME}Release/app-${CI_COMMIT_REF_NAME}-release.aab
      - build/ios/ipa/${CI_COMMIT_REF_NAME}.ipa
  only:
    - dev
    - uat
    - prod

deploy_uat:
  stage: deploy
  image: "google/cloud-sdk:slim"
  before_script:
    - echo $FIREBASE_SERVICE_ACCOUNT_JSON > $CI_PROJECT_DIR/firebase_service_account.json
    - apk add --no-cache ruby ruby-dev
    - gem install fastlane
    - gcloud auth activate-service-account --key-file=$CI_PROJECT_DIR/firebase_service_account.json
  script:
    - |
      # Android Deployment
      gcloud firebase appdistribution apps distribute build/app/outputs/bundle/uatRelease/app-uat-release.aab --app $FIREBASE_APP_ID --groups testers
    - |
      # iOS Deployment
      fastlane ios beta --env uat
  environment: uat
  only:
    - uat

deploy_prod:
  stage: deploy
  image: "alpine:latest"
  before_script:
    - apk add --no-cache ruby ruby-dev openjdk11 bash
    - gem install fastlane
    - curl -o $KEYSTORE_FILE ${CI_JOB_TOKEN}@${CI_SERVER_URL}/api/v4/projects/${CI_PROJECT_ID}/jobs/artifacts/${CI_COMMIT_REF_NAME}/raw/android/app/my-upload-key.jks?job=build
    - curl -o $GOOGLE_PLAY_SERVICE_ACCOUNT_JSON ${CI_JOB_TOKEN}@${CI_SERVER_URL}/api/v4/projects/${CI_PROJECT_ID}/jobs/artifacts/${CI_COMMIT_REF_NAME}/raw/google_play_service_account.json?job=build
  script:
    - |
      # Android Deployment
      fastlane supply --aab build/app/outputs/bundle/prodRelease/app-prod-release.aab --json_key $GOOGLE_PLAY_SERVICE_ACCOUNT_JSON --package_name your.package.name --track production --skip_upload_apk true --skip_upload_metadata true --skip_upload_images true --skip_upload_screenshots true
    - |
      # iOS Deployment
      fastlane ios appstore --env prod
  environment: production
  only:
    - prod

''');

final _androidFastfile = StringBuffer('''
# Fastfile

platform :android do
  desc "Deploy to Google Play for production"
  lane :prod do
    # Production-specific actions for Android
    gradle(task: "bundleRelease")
    upload_to_play_store(track: "production")
  end

  desc "Deploy to Google Play for UAT"
  lane :uat do
    # UAT-specific actions for Android
    gradle(task: "bundleRelease")
    upload_to_play_store(track: "beta")
  end

  desc "Deploy to Firebase App Distribution for dev"
  lane :dev do
    # Development-specific actions for Android
    gradle(task: "bundleRelease")
    firebase_app_distribution(
      app: "<your-firebase-app-id>",
      groups: "dev-testers"
    )
  end
end
''');

final _iosFastlane = StringBuffer('''
default_platform(:ios)

platform :ios do
  desc "Deploy to production"
  lane :prod do
    # Production-specific actions
    match(type: "appstore")
    build_app(scheme: "Runner")
    upload_to_app_store
  end

  desc "Deploy to TestFlight for UAT"
  lane :uat do
    # UAT-specific actions
    match(type: "appstore")
    build_app(scheme: "Runner")
    upload_to_testflight
  end

  desc "Deploy to TestFlight for dev"
  lane :dev do
    # Development-specific actions
    match(type: "development")
    build_app(scheme: "Runner")
    upload_to_testflight
  end
end
''');

final githubAction = StringBuffer(r'''
name: CI/CD Pipeline

on:
  push:
    branches:
      - dev
      - uat
      - prod

jobs:
  code_quality:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: SonarQube code quality analysis
        env:
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
          SONAR_LOGIN: ${{ secrets.SONAR_LOGIN }}
        run: |
          docker run --rm -v $GITHUB_WORKSPACE:/usr/src -w /usr/src sonarsource/sonar-scanner-cli:4.7.0.2747 \
          sonar-scanner -Dsonar.projectKey=my_project -Dsonar.sources=lib -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_LOGIN

  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.3'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: |
          flutter test --machine --coverage --flavor ${{ github.ref }} | tojunit -o report-${{ github.ref }}.xml
          lcov --summary coverage/lcov.info
          genhtml coverage/lcov.info --output=coverage/${{ github.ref }}
        env:
          CI: true

      - name: Upload coverage report
        uses: actions/upload-artifact@v2
        with:
          name: coverage-${{ github.ref }}
          path: coverage/${{ github.ref }}

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.3'

      - name: Build Android
        run: |
          flutter pub get
          flutter build appbundle --flavor ${{ github.ref }} --release

      - name: Build iOS
        run: |
          gem install fastlane
          fastlane ios build --env ${{ github.ref }}
        env:
          FASTLANE_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}

      - name: Upload build artifacts
        uses: actions/upload-artifact@v2
        with:
          name: build-${{ github.ref }}
          path: |
            build/app/outputs/bundle/${{ github.ref }}Release/app-${{ github.ref }}-release.aab
            build/ios/ipa/${{ github.ref }}.ipa

  deploy_uat:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/uat'
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v0.2.0
        with:
          service_account_key: ${{ secrets.GCLOUD_SERVICE_ACCOUNT_KEY }}
          project_id: ${{ secrets.GCLOUD_PROJECT_ID }}

      - name: Deploy to Firebase App Distribution
        run: |
          gcloud firebase appdistribution apps distribute build/app/outputs/bundle/uatRelease/app-uat-release.aab --app ${{ secrets.FIREBASE_APP_ID }} --groups testers

      - name: Deploy to TestFlight for iOS
        run: |
          gem install fastlane
          fastlane ios beta --env uat
        env:
          FASTLANE_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}

  deploy_prod:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/prod'
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v0.2.0
        with:
          service_account_key: ${{ secrets.GCLOUD_SERVICE_ACCOUNT_KEY }}
          project_id: ${{ secrets.GCLOUD_PROJECT_ID }}

      - name: Deploy to Google Play
        run: |
          fastlane supply --aab build/app/outputs/bundle/prodRelease/app-prod-release.aab --json_key ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }} --package_name your.package.name --track production --skip_upload_apk true --skip_upload_metadata true --skip_upload_images true --skip_upload_screenshots true

      - name: Deploy to App Store for iOS
        run: |
          gem install fastlane
          fastlane ios appstore --env prod
        env:
          FASTLANE_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}

''');
