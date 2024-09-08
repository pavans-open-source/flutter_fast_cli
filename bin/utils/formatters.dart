class Formatters {
  String toCamelCase(String str) {
    List<String> words = str.split('_');
    if (words.isEmpty) return str;

    return words.asMap().entries.map((entry) {
      if (entry.key == 0) {
        return entry.value.toLowerCase(); // Lowercase the first word
      } else {
        return capitalize(entry.value); // Capitalize subsequent words
      }
    }).join('');
  }

  String capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

}