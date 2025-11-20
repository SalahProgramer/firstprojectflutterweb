import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/utilities/global/app_global.dart';
import 'APIS/api_birthday_controller.dart';

class BirthdayController extends ChangeNotifier {
  String selectedGender = "";
  String birthday = DateTime.now().toString().substring(0, 10);
  ApiBirthdayController apiBirthdayController =
      NavigatorApp.context.read<ApiBirthdayController>();
  bool isLoading = false;
  bool circleGender = false;

  TextEditingController birthdayProfileController = TextEditingController();

  Future<void> changeSelectGender(String value) async {
    selectedGender = value;
    notifyListeners();
  }

  Future<void> changeControllerBirthday(String value) async {
    birthdayProfileController.text = value;
    notifyListeners();
  }

  Future<void> changeLoading(bool value) async {
    isLoading = value;
    notifyListeners();
  }

  Future<void> changeBirthDay(String value) async {
    birthday = value;
    notifyListeners();
  }

  Future<void> addBirthDay(String phone) async {
    await apiBirthdayController.apiAddBirthday(
      phone: phone,
      isMale: (selectedGender.toString() == "female") ? false : true,
      birthday: birthday,
    );

    notifyListeners();
  }
}
