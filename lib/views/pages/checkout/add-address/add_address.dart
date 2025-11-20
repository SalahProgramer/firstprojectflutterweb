import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controllers/address_provider.dart';
import '../../../../controllers/checkout_controller.dart';
import '../../../../controllers/order_controller.dart';
import '../../../../core/services/database/models_DB/address_item_model.dart';
import '../../../../core/utilities/global/app_global.dart';
import '../../../../core/utilities/style/colors.dart';
import '../../../../core/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../../core/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../../core/widgets/snackBarWidgets/snackbar_widget.dart';
import '../../../../core/widgets/widgets_item_view/button_done.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../models/address/Area/area.dart';
import '../../../../models/address/City/city.dart';

class AddAddress extends StatefulWidget {
  final bool loadAllCities; // true if opened from account_information
  
  const AddAddress({
    super.key,
    this.loadAllCities = false, // Default to false for checkout flow
  });

  @override
  State<AddAddress> createState() => _AddAddressState();
}


class _AddAddressState extends State<AddAddress> {

  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final CheckoutController checkoutController =
      context.read<CheckoutController>();
      
      // If loadAllCities is true, load all cities regardless of dropdownValue
      if (widget.loadAllCities) {
        await checkoutController.setCitiesIgnoreRegion();
      } else {
        await checkoutController.setCities();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    OrderControllerSalah orderControllerSalah =
        context.watch<OrderControllerSalah>();
    CheckoutController checkoutController=context.watch<CheckoutController>();

    return Container(
      color: mainColor,
      child: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: CustomAppBar(
                  title: "فوري",
                  textButton: "رجوع",
                  onPressed: () {
                    NavigatorApp.pop();
                  },
                  actions: [],
                  colorWidgets: Colors.white,
                ),
              ),
              bottomNavigationBar: ButtonDone(
                text: "تأكيد العنوان",
                isLoading: orderControllerSalah.isLoading2,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  final addressProviderFinal =
                      Provider.of<AddressProvider>(context, listen: false);
                  await orderControllerSalah.changeLoading2(true);

                  if (checkoutController.selectedCity != null && (checkoutController.selectedArea) != null) {
                    await orderControllerSalah.changeLoading2(true);

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String userID = prefs.getString('user_id') ?? "";
                    AddressItem newItem = AddressItem(
                      cityName: checkoutController.selectedCity!.translatedName.toString(),
                      areaId: checkoutController.selectedArea!.id.toString(),
                      cityId: checkoutController.selectedCity!.id.toString(),
                      areaName: checkoutController.selectedArea!.name.toString(),
                      userId: userID,
                      name: "${checkoutController.selectedCity!.name}, ${checkoutController.selectedArea!.name}",
                    );

                    await orderControllerSalah.changeLoading2(false);
                    addressProviderFinal.addToAddress(newItem);
                    await showSnackBar(
                        title: "تم اضافة العنوان بنجاح",
                        type: SnackBarType.success);
                    NavigatorApp.pop();
                  } else {
                    await orderControllerSalah.changeLoading2(false);
                    showSnackBar(
                        title: "لم تختر المنطقة أو المنطقة التابعة لها",
                        type: SnackBarType.warning);
                  }
                },
                iconName: Assets.icons.yes,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(right: 25, left: 25, top: 20),
                  child: Column(
                    children: [
                      DropdownSearch<City>(
                        items: (filter, loadProps) => checkoutController.cities,
                        itemAsString: (City c) => c.name,
                        compareFn: (City? a, City? b) =>
                            a?.id == b?.id, // Add comparison logic if needed
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: "اختر المنطقة",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                        onChanged: (City? city) async {
                          await checkoutController.changeCities(city);
                        },
                        selectedItem: checkoutController.selectedCity,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            fit: FlexFit.loose,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "ابحث عن مدينة",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ),
                      ),
                      SizedBox(height: 20.h),
                      // if ((checkoutController.selectedCity) != null)
                        DropdownSearch<Area>(
                          items: (filter, loadProps) => checkoutController.areas,
                          compareFn: (Area? a, Area? b) =>
                              a?.id == b?.id, // Custom comparison logic
                          itemAsString: (Area a) => a.name,
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: "اختر المنطقة التابعة",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                          onChanged: (Area? area) async{
                            await checkoutController.changeArea(area);

                          },
                          selectedItem: checkoutController.selectedArea,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            fit: FlexFit.loose,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "ابحث عن منطقة",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        height: 100.h,
                        width: double.infinity,
                        child: TextField(
                          controller: notesController,
                          obscureText: false,
                          maxLines: 5,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: mainColor, width: 2.0),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1.0, color: mainColor),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            hintText:
                                "المزيد من التفاصيل ( أسم الشارع , معلم مشهور)",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
