import 'package:dcli/dcli.dart';

class Help {
  static void availableOptions() {
    // print(blue('\n-g : it is used to generate files'));
    print(blue('\n-g feature_name : it is used to generate a feature'));
    print(blue('-g assets: it is used to generate asset files'));
    print(blue('-g library_name : it is used to generate library'));
    print(blue('-h --help : it is used to get help\n'));
  }
}
