String getThumbnailUrl(String imageUrl, int width, int height) {
  if (imageUrl.startsWith('https://img.ltwebstatic.com')) {
    int lastIndex = imageUrl.lastIndexOf('.');
    String thumbnailUrl =
        "${imageUrl.substring(0, lastIndex)}_thumbnail_$width$width${imageUrl.substring(lastIndex)}";
    return thumbnailUrl;
  }
  return imageUrl;
}

String intToRoman(int number) {
  const Map<int, String> romanNumerals = {
    1: 'i',
    4: 'iv',
    5: 'v',
    9: 'ix',
    10: 'x',
    40: 'xl',
    50: 'l',
    90: 'xc',
    100: 'c',
    400: 'cd',
    500: 'd',
    900: 'cm',
    1000: 'm'
  };

  String result = '';
  List<int> values = romanNumerals.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  for (int value in values) {
    while (number >= value) {
      result += romanNumerals[value]!;
      number -= value;
    }
  }

  return result;
}
