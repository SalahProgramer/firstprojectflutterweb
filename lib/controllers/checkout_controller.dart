import 'package:fawri_app_refactor/controllers/points_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/checkout/area_city_service/area_city_service.dart';
import '../core/utilities/global/app_global.dart';
import '../models/address/Area/area.dart';
import '../models/address/City/city.dart';
import 'address_provider.dart';

class CheckoutController extends ChangeNotifier {
  String dropdownValue = 'اختر منطقتك';
  double deliveryPrice = 0.0;

  String finalSelectedArea = "";
  City? selectedCity;
  Area? selectedArea;
  List<City> cities = [];
  List<Area> areas = [];
  final addressItems =
      NavigatorApp.context.read<AddressProvider>().addressItems;

  Future<void> changeDropdownValue(String value) async {
    dropdownValue = value;
    // تحديث المدن بناءً على المنطقة الجديدة
    await setCities();
    notifyListeners();
  }

  Future<void> resetDropdownValue() async {
    dropdownValue = "اختر منطقتك";

    notifyListeners();
  }

  Future<void> changeDeliveryPrice(
      dynamic freeShipValue, PointsController pointsController,
      {bool doClear = false}) async {

    if(doClear){

      await resetDropdownValue();
    }

    if (dropdownValue == "الداخل") {
      deliveryPrice = 60.0;
    } else if (dropdownValue == "القدس") {
      deliveryPrice = 30.0;
    } else if (dropdownValue == "الضفه الغربيه") {
      deliveryPrice = 20.0;
    } else {
      deliveryPrice = 0.0;
    }

    if (dropdownValue == "اختر منطقتك") {
      deliveryPrice = 0.0;
    } else {
      if (int.parse(freeShipValue.toString()) == 0) {
        deliveryPrice = deliveryPrice;
      } else {
        if (pointsController.total >= int.parse(freeShipValue.toString())) {
          deliveryPrice = deliveryPrice - 20;
        }
      }
    }
    notifyListeners();
  }

  Future<void> changeValueDeliveryPrice(double value) async {
    deliveryPrice = value;
    notifyListeners();
  }

  Future<void> setCities() async {
    // تحميل المدن بناءً على المنطقة المختارة (dropdownValue)
    if (dropdownValue != "" && dropdownValue != "اختر منطقتك") {
      cities = await CityService().loadCitiesByRegion(dropdownValue);
    } else {
      cities = await CityService().loadCities();
    }
    
    if (addressItems.isNotEmpty && selectedArea == null) {
      finalSelectedArea = addressItems[0].name;
    }

    // مسح المدينة المختارة عند تغيير المنطقة لضمان اختيار مدينة من القائمة الجديدة
    if (selectedCity != null && !cities.any((city) => city.name == selectedCity!.name)) {
      selectedCity = null;
      selectedArea = null;
      areas = [];
    }
    
    notifyListeners();
  }

  // Load all cities regardless of dropdownValue (used in account_information)
  Future<void> setCitiesIgnoreRegion() async {
    cities = await CityService().loadCities();
    
    if (addressItems.isNotEmpty && selectedArea == null) {
      finalSelectedArea = addressItems[0].name;
    }
    
    // Clear selected city and area when loading all cities
    selectedCity = null;
    selectedArea = null;
    areas = [];
    
    notifyListeners();
  }

  Future<void> changeCities(City? city) async {
    selectedCity = city;
    selectedArea = null;
    areas = [];
    areas = await CityService().loadAreasFromCsv(city!);
    notifyListeners();
  }

  Future<void> changeArea(Area? area) async {
    selectedArea = area;
    notifyListeners();
  }
}
