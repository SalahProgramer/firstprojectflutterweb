import 'package:fawri_app_refactor/fawri_main/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../views/pages/pages.dart';
import '../../views/pages/home/main_screen/product_item_view.dart';
import '../../views/pages/cart/my_cart.dart';
import '../../views/pages/checkout/first-screen/first_screen.dart';
import '../../views/pages/checkout/second-screen/second_screen.dart';
import '../../views/pages/checkout/add-address/add_address.dart';
import '../../views/pages/orders/new_orders.dart';
import '../../views/pages/orders/order_details.dart';
import '../../views/pages/account_information/account_information.dart';
import '../../views/pages/points/users_points.dart';
import '../../views/pages/chooses_birthdate/chooses_birthdate.dart';
import '../../views/pages/departments/page_dapartment.dart';
import '../../views/pages/home/home_screen/home_screen.dart';
import '../../views/pages/spining_wheel/spin_wheel.dart';
import '../../views/pages/searchandfilterandgame/widget_filter.dart';
import '../../views/pages/searchandfilterandgame/main_search.dart';
import '../../views/pages/home/main_screen/survey_form_page.dart';
import '../../views/pages/checkout_order/first_screen_checkout/check_points_order.dart';
import '../../views/pages/splash_link.dart';
import '../../views/login/login_screen.dart';
import '../../views/pages/departments/departs/men.dart';
import '../../views/pages/departments/departs/women.dart';
import '../../views/pages/departments/departs/women_plus.dart';
import '../../views/pages/departments/departs/underware.dart';
import '../../views/pages/departments/departs/perfume.dart';
import '../../views/pages/departments/departs/shoes_types/shoes.dart';
import '../../views/pages/departments/departs/shoes_types/men_shoes.dart';
import '../../views/pages/departments/departs/shoes_types/women_shoes.dart';
import '../../views/pages/departments/departs/shoes_types/kids_shoes.dart';
import '../../views/pages/departments/departs/kids_types/kids_all.dart';
import '../../views/pages/departments/departs/kids_types/boy_kids.dart';
import '../../views/pages/departments/departs/kids_types/girl_kids.dart';
import '../../views/pages/searchandfilterandgame/game.dart';
import '../../models/items/item_model.dart';
import '../../core/services/database/models_DB/cart_model.dart';
import '../../models/order/order_detail_model.dart';
import '../../models/constants/constant_model.dart';
import '../../core/widgets/widgets_item_view/pop_up_shoes.dart';
import '../../core/widgets/widget_orders/specific_description_item_in_order.dart';
import '../../models/order/order.dart';

// Route name constants
class AppRoutes {
  static const String splash = '/';
  static const String pages = '/pages';
  static const String productItemView = '/product-item-view';
  static const String myCart = '/my-cart';
  static const String checkoutFirstScreen = '/checkout-first-screen';
  static const String checkoutSecondScreen = '/checkout-second-screen';
  static const String addAddress = '/add-address';
  static const String ordersPages = '/orders-pages';
  static const String orderDetails = '/order-details';
  static const String accountInformation = '/account-information';
  static const String usersPointsPage = '/users-points-page';
  static const String chooseBirthdate = '/choose-birthdate';
  static const String pageDepartment = '/page-department';
  static const String homeScreen = '/home-screen';
  static const String spinWheel = '/spin-wheel';
  static const String widgetFilter = '/widget-filter';
  static const String mainSearch = '/main-search';
  static const String surveyFormPage = '/survey-form-page';
  static const String checkPointsOrder = '/check-points-order';
  static const String splashLink = '/splash-link';
  static const String loginScreen = '/login-screen';
  static const String men = '/men';
  static const String women = '/women';
  static const String womenPlus = '/women-plus';
  static const String underware = '/underware';
  static const String perfume = '/perfume';
  static const String shoes = '/shoes';
  static const String menShoes = '/men-shoes';
  static const String womenShoes = '/women-shoes';
  static const String kidsShoes = '/kids-shoes';
  static const String kidsAll = '/kids-all';
  static const String boyKids = '/boy-kids';
  static const String girlKids = '/girl-kids';
  static const String widgetGame = '/widget-game';
  static const String popUpShoes = '/pop-up-shoes';
  static const String specificDescriptionItemInOrder = '/specific-description-item-in-order';
}

Map<String, Widget Function(BuildContext, Object?)> listRoute = {
  AppRoutes.splash: (context, arguments) => ShowCaseWidget(
        builder: (context) => const Splash(),
      ),
  AppRoutes.pages: (context, arguments) => const Pages(),
  AppRoutes.productItemView: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return ProductItemView(
      item: args['item'] as Item,
      isFeature: args['isFeature'] as bool? ?? false,
      isFlashOrBest: args['isFlashOrBest'] as bool? ?? false,
      sizes: args['sizes'] as String? ?? '',
      indexVariants: args['indexVariants'] as int? ?? 0,
    );
  },
  AppRoutes.myCart: (context, arguments) => const MyCart(),
  AppRoutes.checkoutFirstScreen: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return CheckoutFirstScreen(
      items: args['items'] as List<CartModel>,
      freeShipValue: args['freeShipValue'],
    );
  },
  AppRoutes.checkoutSecondScreen: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return CheckoutSecondScreen(
      total: args['total'] as dynamic,
      totalWithoutDelivery: args['totalWithoutDelivery'] as dynamic,
      delivery: args['delivery'] as dynamic,
      initialCity: args['initialCity'] as String? ?? '',
      couponControllerText: args['couponControllerText'] as String? ?? '',
      pointControllerText: args['pointControllerText'] as String? ?? '',
      usedWheelCoupon: args['usedWheelCoupon'] as bool? ?? false,
    );
  },
  AppRoutes.addAddress: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return AddAddress(
      loadAllCities: args['loadAllCities'] as bool? ?? false,
    );
  },
  AppRoutes.ordersPages: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return OrdersPages(
      phone: args['phone'] as String? ?? '',
      userId: args['userId'] as String? ?? '',
    );
  },
  AppRoutes.orderDetails: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return OrderDetails(
      done: args['done'] as bool? ?? false,
      newestOrder: args['newestOrder'] as OrderDetailModel,
    );
  },
  AppRoutes.accountInformation: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return AccountInformation(
      name: args['name'],
      address: args['address'],
      area: args['area'],
      city: args['city'],
      phone: args['phone'],
      birthday: args['birthday'],
    );
  },
  AppRoutes.usersPointsPage: (context, arguments) => const UsersPointsPage(),
  AppRoutes.chooseBirthdate: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return ChooseBirthdate(
      name: args['name'] as String,
      userID: args['userID'] as String,
      phoneController: args['phoneController'] as String,
      token: args['token'] as String,
      selectedArea: args['selectedArea'] as String,
      select: args['select'] as int,
    );
  },
  AppRoutes.pageDepartment: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return PageDapartment(
      title: args['title'] as String,
      sizes: args['sizes'] as String? ?? '',
      category: args['category'] as CategoryModel,
      showIconSizes: args['showIconSizes'] as bool? ?? true,
      scrollController: args['scrollController'] as ScrollController? ?? ScrollController(),
    );
  },
  AppRoutes.homeScreen: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return HomeScreen(
      slider: args['slider'] as bool? ?? false,
      productsKinds: args['productsKinds'] as bool? ?? false,
      hasAppBar: args['hasAppBar'] as bool? ?? false,
      url: args['url'] as String? ?? '',
      title: args['title'] as String? ?? '',
      endDate: args['endDate'] as String? ?? '',
      bannerTitle: args['bannerTitle'] as String? ?? '',
      scrollController: args['scrollController'] as ScrollController? ?? ScrollController(),
      type: args['type'] ?? 'normal',
      i: args['i'] as int? ?? 0,
      haveScaffold: args['haveScaffold'] as bool? ?? true,
    );
  },
  AppRoutes.spinWheel: (context, arguments) => const SpinWheel(),
  AppRoutes.widgetFilter: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return WidgetFilter(
      scrollController: args['scrollController'] as ScrollController? ?? ScrollController(),
    );
  },
  AppRoutes.mainSearch: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return MainSearch(
      scrollController: args['scrollController'] as ScrollController? ?? ScrollController(),
    );
  },
  AppRoutes.surveyFormPage: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return SurveyFormPage(
      url: args['url'] as String,
    );
  },
  AppRoutes.checkPointsOrder: (context, arguments) => const CheckPointsOrder(),
  AppRoutes.splashLink: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return SplashLink(
      id: args['id'] as String,
    );
  },
  AppRoutes.loginScreen: (context, arguments) => const LoginScreen(),
  AppRoutes.men: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return Men(
      category: args['category'] as CategoryModel,
    );
  },
  AppRoutes.women: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return Women(
      category: args['category'] as CategoryModel,
    );
  },
  AppRoutes.womenPlus: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return WomenPlus(
      category: args['category'] as CategoryModel,
    );
  },
  AppRoutes.underware: (context, arguments) => const Underware(),
  AppRoutes.perfume: (context, arguments) => const PerfumeHome(),
  AppRoutes.shoes: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return Shoes(
      category: args['category'] as CategoryModel,
    );
  },
  AppRoutes.menShoes: (context, arguments) => const MenShoes(),
  AppRoutes.womenShoes: (context, arguments) => const WomenShoes(),
  AppRoutes.kidsShoes: (context, arguments) => const KidsShoes(),
  AppRoutes.kidsAll: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return KidsAll(
      category: args['category'] as CategoryModel,
    );
  },
  AppRoutes.boyKids: (context, arguments) => const BoyKids(),
  AppRoutes.girlKids: (context, arguments) => const GirlKids(),
  AppRoutes.widgetGame: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return CustomGameWidget(
      haveSort: args['haveSort'] as bool? ?? false,
    );
  },
  AppRoutes.popUpShoes: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return PopUpShoes(
      isMale: args['isMale'] as bool? ?? true,
    );
  },
  AppRoutes.specificDescriptionItemInOrder: (context, arguments) {
    final args = arguments as Map<String, dynamic>? ?? {};
    return SpecificDescriptionItemInOrder(
      item: args['item'] as Item,
      indexVariants: args['indexVariants'] as int,
      isFavourite: args['isFavourite'] as bool,
      specificOrder: args['specificOrder'] as SpecificOrder,
    );
  },
};
