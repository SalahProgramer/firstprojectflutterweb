import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../models/address/Area/area.dart';
import '../../../../models/address/City/city.dart';
import '../../../utilities/print_looger.dart';

class CityService {
  final Map<String, List<int>> cityInfo = {

    'أريحا': [11, 0, 8],
    'الخليل': [6, 27, 88],
    'القدس': [1240, 90, 134],
    'بيت لحم': [8, 136, 186],
    'جنين': [7, 187, 263],
    'سلفيت': [9, 354, 371],
    'طوباس': [10, 372, 384],
    'طولكرم': [4, 385, 417],
    'القدس الشرقية': [386401, 419, 445],
    'مناطق الداخل': [23, 477, 701],
    'قلقيلة': [2, 446, 478],
    'ايلات': [314850, 135, 136],
    'الجولان': [173, 9, 26],
    'نابلس': [1, 708, 769],
    '67 مناطق الداخل': [386406, 702, 707],
    'رام الله': [5, 264, 354],
  };

  final Map<String, String> cityTranslations = {
    'أريحا': 'Jericho',
    'الخليل': 'Hebron',
    'القدس': 'Quds',
    'بيت لحم': 'beitlahm',
    'جنين': 'Jenin',
    'سلفيت': 'Salfit',
    'طوباس': 'Tubas',
    'طولكرم': 'Tulkarem',
    'القدس الشرقية': 'QudsV',
    'مناطق الداخل': 'Manateq',
    'قلقيلة': 'Qaliqilya',
    'ايلات': 'Eilat',
    'الجولان': 'Jolan',
    'نابلس': 'Nablus',
    '67 مناطق الداخل': 'AL 67',
    'رام الله': 'Ramallah',
  };

  Future<List<City>> loadCities() async {
    return cityInfo.entries
        .map((entry) => City(
            name: entry.key,
            translatedName:
                cityTranslations[entry.key] ?? entry.key, // Add translation
            id: entry.value[0],
            startIndex: entry.value[1],
            endIndex: entry.value[2]))
        .toList();
  }

  // Load cities based on region (dropdownValue)
  Future<List<City>> loadCitiesByRegion(String region) async {
    List<String> citiesForRegion = [];

    if (region == "الداخل") {
      // المدن الخاصة بالداخل
      citiesForRegion = ['ايلات', 'الجولان', 'مناطق الداخل', '67 مناطق الداخل'];
    } else if (region == "القدس") {
      // المدن الخاصة بالقدس
      citiesForRegion = ['القدس'];
    } else if (region == "الضفه الغربيه") {
      // المدن الخاصة بالضفة الغربية
      citiesForRegion = [
        'نابلس',
        'رام الله',
        'جنين',
        'طولكرم',
        'قلقيلة',
        'الخليل',
        'بيت لحم',
        'أريحا',
        'سلفيت',
        'طوباس',
        'القدس الشرقية',
      ];
    } else {
      // إذا لم يتم اختيار منطقة، إرجاع كل المدن
      return loadCities();
    }

    // فلترة المدن بناءً على المنطقة المختارة
    return cityInfo.entries
        .where((entry) => citiesForRegion.contains(entry.key))
        .map((entry) => City(
            name: entry.key,
            translatedName: cityTranslations[entry.key] ?? entry.key,
            id: entry.value[0],
            startIndex: entry.value[1],
            endIndex: entry.value[2]))
        .toList();
  }

  Future<List<Area>> loadAreasFromCsv(City city) async {

      final data = await rootBundle.loadString(
        Assets.pdfs.citiesAreas,
      );

      final List<List<dynamic>> rows =
          data.split('\n').map((line) => line.split(',')).toList();

      if (rows.isEmpty || rows.length < 2) {
        return []; // Return empty if not enough data
      }

      List<Area> areas = [];

      // Iterate through all rows and filter by matching city name in English (column 2)
      for (int i = 0; i < rows.length; i++) {
        if (rows[i].length >= 4) {
          String cityNameInEnglish = rows[i][2].toString().trim();
          
          // Check if the city name matches
          if (cityNameInEnglish == city.translatedName) {
            String name = rows[i][0].toString().trim(); // Area name in Arabic
            int id = int.tryParse(rows[i][1].toString()) ?? 0;

            areas.add(Area(name: name, id: id, cityId: city.id));
          }
        } else if (rows[i].isNotEmpty && rows[i][0].toString().trim().isNotEmpty) {
          printLog('Row $i is missing data: ${rows[i]}');
        }
      }

      return areas;
    }

}
