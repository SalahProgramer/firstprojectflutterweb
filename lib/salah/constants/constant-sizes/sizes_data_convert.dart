// This file provides backward compatibility by exporting sizes data
// from the new SizesDataService in the old format

import 'package:fawri_app_refactor/salah/constants/constant-sizes/sizes_data_service.dart';

// Men Sizes
Map<String, String> get menSizesList => SizesDataService.instance.menSizesList;

Map<String, bool> get menSizesMap => SizesDataService.instance.menSizesMap;

// Women Sizes
Map<String, String> get womenSizesList =>
    SizesDataService.instance.womenSizesList;

Map<String, bool> get womenSizesMap => SizesDataService.instance.womenSizesMap;

// Women Plus Sizes
Map<String, String> get womenPlusSizesList =>
    SizesDataService.instance.womenPlusSizesList;

// Kids Boys Sizes
List<String> get kidsBoysSizesList =>
    SizesDataService.instance.kidsBoysSizesList;

Map<String, bool> get kidsBoysSizesData =>
    SizesDataService.instance.kidsBoysSizesData;

// Kids Girls Sizes
List<String> get girlsKidsSizesList =>
    SizesDataService.instance.girlsKidsSizesList;

Map<String, bool> get girlsKidsSizesData =>
    SizesDataService.instance.girlsKidsSizesData;

// Women Shoes Sizes
List<String> get womenShoesSizesList =>
    SizesDataService.instance.womenShoesSizesList;

Map<String, bool> get womenShoesSizesData =>
    SizesDataService.instance.womenShoesSizesData;

// Men Shoes Sizes
List<String> get menShoesSizesList =>
    SizesDataService.instance.menShoesSizesList;

Map<String, bool> get menShoesSizesData =>
    SizesDataService.instance.menShoesSizesData;

// Kids Shoes Sizes
List<String> get kidsShoesSizesList =>
    SizesDataService.instance.kidsShoesSizesList;

Map<String, bool> get kidsShoesSizesData =>
    SizesDataService.instance.kidsShoesSizesData;

// Underwear Sizes
List<String> get underwearSizes => SizesDataService.instance.underwearSizes;

Map<String, bool> get underwearSleepwearSizesData =>
    SizesDataService.instance.underwearSleepwearSizesData;

// Wedding and Events Sizes
Map<String, bool> get weddingAndEventsData =>
    SizesDataService.instance.weddingAndEventsData;

// Women and Baby (Infant) Sizes
List<String> get womenAndBabySizesList =>
    SizesDataService.instance.womenAndBabySizesList;

Map<String, bool> get womenAndBabySizesData =>
    SizesDataService.instance.womenAndBabySizesData;
