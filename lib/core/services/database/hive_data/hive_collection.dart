import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import 'data_sizes.dart';

class HiveCollection extends ChangeNotifier {
  Box? boxSizes;

  Future<Box> initialHive(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      //if not created before
      Hive.init((await getApplicationDocumentsDirectory()).path);
    }
    return await Hive.openBox(boxName);
  }

  Future<void> initialGetCollection() async {
    boxSizes = await initialHive("sizes");
    setSizes();
    notifyListeners();
  }

  //sizes-------------------------------------------------------------------

  Future<void> setSizes() async {
    boxSizes?.put("menSizesMap", menSizesMap);
    boxSizes?.put("womenSizesMap", womenSizesMap);
    boxSizes?.put("kidsBoysSizesData", kidsBoysSizesData);
    boxSizes?.put("girlsKidsSizesData", girlsKidsSizesData);
    boxSizes?.put("kidsShoesSizesData", kidsShoesSizesData);
    boxSizes?.put("menShoesSizesData", menShoesSizesData);
    boxSizes?.put("womenShoesSizesData", womenShoesSizesData);
    boxSizes?.put("weddingAndEventsData", weddingAndEventsData);
    boxSizes?.put("underwearSleepwearSizesData", underwearSleepwearSizesData);
  }
}
