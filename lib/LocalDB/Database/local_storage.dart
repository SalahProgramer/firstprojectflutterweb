import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static LocalStorage instance = LocalStorage._();
  LocalStorage._();
  factory LocalStorage() {
    return instance;
  }
  late final dynamic favoriteDataBox, sizeDataBox;

  Future<void> initHive() async {
    await Hive.initFlutter();
    favoriteDataBox = await Hive.openBox('favoriteData');
    sizeDataBox = await Hive.openBox('sizeData');
    setSize();
  }

  //user images

  setStartSize() {
    sizeDataBox.put('startSize', true);
  }

  setStartCart() {
    sizeDataBox.put('startCart', true);
  }

  List<String> menSizes = [
    "XS 👔",
    "S 👖",
    "M 👖",
    "L 👖",
    "XL 🧥",
    "XXL 👔",
    "XXXL 👔",
    "0XL 👖",
    "1XL 👖",
    "2XL 👕",
    "3XL 👖",
    "4XL 👕",
    "5XL 👖",
    "6XL 👕",
  ];
  List<String> womenSizes = [
    "XXS 👚",
    "XS 👗",
    "S 🩱",
    "M 🩱",
    "L 🩱",
    "XL 🩱",
    "XXL 👘",
    "XXXL 🧥",
  ];
  var womenPlusSizes = ["0XL", "1XL", "2XL", "3XL", "4XL", "5XL"];
  List<String> kidsBoysSizes = [
    "6-9 شهر",
    "9-12 شهر",
    "S"
        "2سنة",
    "2-3سنة",
    "3سنة",
    "4سنة",
    "5سنة",
    "5-6سنة",
    "6سنة",
    "7سنة",
    "8 سنة",
    "9 سنة",
    "10 سنة",
    "9-10 سنة",
    "11-12 سنة",
    "12 سنة",
    "12-13 سنة",
    "13-14 سنة",
  ];

  void setSize() async {
    sizeDataBox.put('menSizes', {
      "XS": false,
      "S": false,
      "M": false,
      "L": false,
      "XL": false,
      "XXL": false,
      "XXXL": false,
      "0XL": false,
      "1XL": false,
      "2XL": false,
      "3XL": false,
      "4XL": false,
      "5XL": false,
      "6XL": false,
    });
    sizeDataBox.put('womenSizes', {
      "XXS": false,
      "XS": false,
      "S": false,
      "M": false,
      "L": false,
      "XL": false,
      "XXL": false,
      "XXXL": false,
    });
    sizeDataBox.put('womenPlusSizes', {
      "0XL": false,
      "1XL": false,
      "2XL": false,
      "3XL": false,
      "4XL": false,
      "5XL": false,
    });
    sizeDataBox.put('kidsboysSizes', {
      "2سنة": false,
      "2-3سنة": false,
      "3سنة": false,
      "4سنة": false,
      "5سنة": false,
      "5-6سنة": false,
      "6سنة": false,
      "7سنة": false,
      "8 سنة": false,
      "9 سنة": false,
      "10 سنة": false,
      "9-10 سنة": false,
      "11-12 سنة": false,
      "12 سنة": false,
      "12-13 سنة": false,
      "13-14 سنة": false,
    });
    sizeDataBox.put('girls_kids_sizes', {
      "2سنة": false,
      "2-3سنة": false,
      "3سنة": false,
      "4سنة": false,
      "5سنة": false,
      "5-6سنة": false,
      "6سنة": false,
      "7سنة": false,
      "8 سنة": false,
      "9 سنة": false,
      "9-10 سنة": false,
      "10 سنة": false,
      "11-12 سنة": false,
      "12 سنة": false,
      "12-13 سنة": false,
      "13-14 سنة": false,
    });
    sizeDataBox.put('Kids_shoes_sizes', {
      "21": false,
      "23": false,
      "24": false,
      "25": false,
      "26": false,
      "27": false,
      "28": false,
      "29": false,
      "30": false,
      "31": false,
      "32": false,
      "33": false,
      "34": false,
    });
    sizeDataBox.put('Men_shoes_sizes', {
      "37": false,
      "39": false,
      "40": false,
      "41": false,
      "42": false,
      "43": false,
      "44": false,
      "45": false,
      "46": false,
      "47": false,
    });
    sizeDataBox.put('Women_shoes_sizes', {
      "35": false,
      "36": false,
      "37": false,
      "38": false,
      "39": false,
      "39-40": false,
      "40": false,
      "41": false,
      "42": false,
      "43": false,
      "44": false,
    });
    sizeDataBox.put('Weddings & Events', {
      "0XL": false,
      "1XL": false,
      "24": false,
      "2XL": false,
      "3XL": false,
      "44": false,
      "4XL": false,
      "5XL": false,
      "L": false,
      "M": false,
      "S": false,
      "XL": false,
      "XS": false,
      "XXL": false,
    });
    sizeDataBox.put('Underwear_Sleepwear_sizes', {
      "XS": false,
      "S": false,
      "M": false,
      "L": false,
      "XL": false,
      "XXL": false,
      "0XL": false,
      "1XL": false,
      "2XL": false,
      "3XL": false,
      "4XL": false,
      "5XL": false,
    });
  }

  void editSize(key, v) async {
    sizeDataBox.put(key, v);
  }

  getSize(type) {
    if (type == "menSizes") {
      return sizeDataBox.get('menSizes', defaultValue: []);
    }
    if (type == "Underwear_Sleepwear_sizes") {
      return sizeDataBox.get('Underwear_Sleepwear_sizes', defaultValue: []);
    }
    if (type == "womenSizes") {
      return sizeDataBox.get('womenSizes', defaultValue: []);
    }
    if (type == "womenPlusSizes") {
      return sizeDataBox.get('womenPlusSizes', defaultValue: []);
    }
    if (type == "kidsboysSizes") {
      return sizeDataBox.get('kidsboysSizes', defaultValue: []);
    }
    if (type == "girls_kids_sizes") {
      return sizeDataBox.get('girls_kids_sizes', defaultValue: []);
    }
    if (type == "Kids_shoes_sizes") {
      return sizeDataBox.get('Kids_shoes_sizes', defaultValue: []);
    }
    if (type == "Men_shoes_sizes") {
      return sizeDataBox.get('Men_shoes_sizes', defaultValue: []);
    }
    if (type == "Women_shoes_sizes") {
      return sizeDataBox.get('Women_shoes_sizes', defaultValue: []);
    }
    if (type == "Weddings & Events") {
      return sizeDataBox.get('Weddings & Events', defaultValue: []);
    }
  }

  setSizeUser(data) {
    sizeDataBox.put('sizeUser', data);
  }

  void deleteFavorite(String id) async {
    List data = favorites;
    for (int i = 0; i < data.length; i++) {
      if (data[i]["id"].toString() == id.toString()) {
        data.removeAt(i);
      }
    }
    favoriteDataBox.put('favorites', data);
  }

  isFavorite(String id) {
    bool favorite = false;
    for (int i = 0; i < favorites.length; i++) {
      if (favorites[i]["id"].toString() == id.toString()) {
        favorite = true;
      }
    }
    return favorite;
  }

  List getFavorites() {
    List data = favoriteDataBox.get('favorites', defaultValue: []);
    return data;
  }

  List<dynamic> get favorites =>
      favoriteDataBox.get('favorites', defaultValue: []);
  List<dynamic> get userAddress =>
      favoriteDataBox.get('users_addresses', defaultValue: []);
  List get sizeUser => sizeDataBox.get('sizeUser', defaultValue: []);
  bool get startSize => sizeDataBox.get('startSize', defaultValue: false);
  bool get startCart => sizeDataBox.get('startCart', defaultValue: false);
}
