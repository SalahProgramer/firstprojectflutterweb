import "package:provider/provider.dart";
import "package:provider/single_child_widget.dart";
import "../../controllers/APIS/api_birthday_controller.dart";
import "../../controllers/APIS/api_cart_controller.dart";
import "../../controllers/APIS/api_departments_controller.dart";
import "../../controllers/APIS/api_main_product_controller.dart";
import "../../controllers/APIS/api_order_controlller.dart";
import "../../controllers/APIS/api_page_main_controller.dart";
import "../../controllers/APIS/api_points_controller.dart";
import "../../controllers/APIS/api_product_item.dart";
import "../../controllers/APIS/api_rating_controller.dart";
import "../../controllers/address_provider.dart";
import "../../controllers/birthday_controller.dart";
import "../../controllers/cart_controller.dart";
import "../../controllers/checkout_controller.dart";
import "../../controllers/checks_controller.dart";
import "../../controllers/custom_page_controller.dart";
import "../../controllers/departments_controller.dart";
import "../../controllers/favourite_controller.dart";
import "../../controllers/fetch_controller.dart";
import "../../controllers/free_gift_controller.dart";
import "../../controllers/game_controller.dart";
import "../../controllers/main_product_controller.dart";
import "../../controllers/notification_controller.dart";
import "../../controllers/order_controller.dart";
import "../../controllers/page_main_screen_controller.dart";
import "../../controllers/points_controller.dart";
import "../../controllers/product_item_controller.dart";
import "../../controllers/rating_controller.dart";
import "../../controllers/search_controller.dart";
import "../../controllers/showcase_controller.dart";
import "../../controllers/sub_main_categories_conrtroller.dart";
import "../../controllers/timer_controller.dart";
import "../../controllers/user_controller.dart";
import "../../controllers/wheel_controller.dart";
import "../services/database/hive_data/hive_collection.dart";


List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => AddressProvider()),
  ChangeNotifierProvider(create: (_) => ChecksController()),
  ChangeNotifierProvider(create: (_) => UserController()),
  ChangeNotifierProvider(create: (_) => CustomPageController()),
  ChangeNotifierProvider(create: (_) => CartController()),
  ChangeNotifierProvider(create: (_) => ApiCartController()),
  ChangeNotifierProvider(create: (_) => FetchController()),
  ChangeNotifierProvider(create: (_) => PageMainScreenController()),
  ChangeNotifierProvider(create: (_) => ProductItemController()),
  ChangeNotifierProvider(create: (_) => OrderControllerSalah()),
  ChangeNotifierProvider(create: (_) => ApiPageMainController()),
  ChangeNotifierProvider(create: (_) => ApiProductItemController()),
  ChangeNotifierProvider(create: (_) => TimerController()),
  ChangeNotifierProvider(create: (_) => FavouriteController()),
  ChangeNotifierProvider(create: (_) => MainProductController()),
  ChangeNotifierProvider(create: (_) => ApiMainProductController()),
  ChangeNotifierProvider(create: (_) => BirthdayController()),
  ChangeNotifierProvider(create: (_) => ApiBirthdayController()),
  ChangeNotifierProvider(create: (_) => SubMainCategoriesController()),
  ChangeNotifierProvider(create: (_) => DepartmentsController()),
  ChangeNotifierProvider(create: (_) => ApiDepartmentsController()),
  ChangeNotifierProvider(create: (_) => SearchItemController()),
  ChangeNotifierProvider(create: (_) => HiveCollection()),
  ChangeNotifierProvider(create: (_) => PointsController()),
  ChangeNotifierProvider(create: (_) => WheelController()),
  ChangeNotifierProvider(create: (_) => FreeGiftController()),
  ChangeNotifierProvider(create: (_) => RatingController()),
  ChangeNotifierProvider(create: (_) => ApiRatingController()),
  ChangeNotifierProvider(create: (_) => ApiOrderController()),
  ChangeNotifierProvider(create: (_) => GameController()),
  ChangeNotifierProvider(create: (_) => ApiPointsController()),
  ChangeNotifierProvider(create: (_) => NotificationController()),
  ChangeNotifierProvider(create: (_) => ShowcaseController()),
  ChangeNotifierProvider(create: (_) => CheckoutController()),
];
