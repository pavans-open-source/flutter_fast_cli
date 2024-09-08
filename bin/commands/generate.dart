import '../commands/asset_generator.dart';
import '../commands/feature_generator.dart';
import '../commands/library_generator.dart';

class Generate {
  onAssetGenerate()async {
    AssetGenerator().onGenerateAssets();
  }

   onLibraryGenerate(String? libraryName) {
    print('Generating library...');
    LibraryGenerator().onGenerateLibrary(libraryName);
  }

  onFeatureGenerate( String? featureName){
    print('Generating feature...');
    FeatureGenerator().onGenerateFeature(featureName);
  }
}


/// Function to capitalize the first letter of a string.


/// Function to convert a string with underscores into camelCase.


/// Function to update the pubspec.yaml file with the new assets section.

/// Generate a Dart file for each feature with the asset paths.
