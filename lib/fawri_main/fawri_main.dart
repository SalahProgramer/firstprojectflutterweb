
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Cubits/cubit_connection/internet_cubit.dart';
import '../controllers/cart_controller.dart';
import '../controllers/checks_controller.dart';
import '../controllers/favourite_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/product_item_controller.dart';
import '../controllers/showcase_controller.dart';
import '../core/constants/constant_data/categories_data_service.dart';
import '../core/dialogs/dialog_connected_wifi/dialog_connect_wifi.dart';
import '../core/utilities/routes.dart';
import '../core/services/database/hive_data/hive_collection.dart';
import '../core/services/locator.dart';
import '../core/services/notifications/notification_service.dart';
import '../core/services/sentry/sentry_service.dart';
import '../core/utilities/global/app_global.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../games/audio_helper.dart';
import '../games/games_cubit.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class Fawri extends StatefulWidget {
  const Fawri({super.key});

  @override
  State<Fawri> createState() => _FawriState();
}

class _FawriState extends State<Fawri> {
  bool isDialogShowing = false;
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      await initializeApp();
    });
  }

  /// Initialize app with parallel execution and comprehensive error handling
  Future<void> initializeApp() async {
    try {
      // Get all required controllers
      final ChecksController checksController = context.read<ChecksController>();
      final CartController cartController = context.read<CartController>();
      final ProductItemController productItemController =
          context.read<ProductItemController>();
      final HiveCollection hiveCollection = context.read<HiveCollection>();
      final FavouriteController favouriteController =
          context.read<FavouriteController>();
      final NotificationController notificationController =
          context.read<NotificationController>();
      final ShowcaseController showcaseController =
          context.read<ShowcaseController>();
      // Initialize Categories Data Service
      await CategoriesDataService.instance.initialize();
      // Initialize showcase controller
      await showcaseController.init();

      // Phase 2: Parallel execution of independent SharedPreferences operations
      await initializeSharedPreferences(
        hiveCollection: hiveCollection,
        productItemController: productItemController,
        checksController: checksController,
        cartController: cartController,
      );

      // Phase 3: Parallel execution of database operations
      await initializeDataFromDatabase(
        cartController: cartController,
        favouriteController: favouriteController,
        notificationController: notificationController,
      );

      
      // Phase 4: Schedule notifications if enabled
      await scheduleNotificationsIfNeeded(
        notificationController: notificationController,
        cartController: cartController,
      );
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: '_initializeApp',
        fileName: 'fawri_main.dart',
        lineNumber: 43,
      );
    }
  }

  /// Initialize SharedPreferences data in parallel
  Future<void> initializeSharedPreferences({
    required HiveCollection hiveCollection,
    required ProductItemController productItemController,
    required ChecksController checksController,
    required CartController cartController,
  }) async {
    try {
      await Future.wait<void>([
        hiveCollection.initialGetCollection().catchError((e, stack) {
          SentryService.captureError(
            exception: e,
            stackTrace: stack,
            functionName: '_initializeSharedPreferences (Hive)',
            fileName: 'fawri_main.dart',
            lineNumber: 117,
          );
          throw e;
        }),
        productItemController.checkFirstOpenItem().catchError((e, stack) {
          SentryService.captureError(
            exception: e,
            stackTrace: stack,
            functionName: '_initializeSharedPreferences (ProductItem)',
            fileName: 'fawri_main.dart',
            lineNumber: 127,
          );
          throw e;
        }),
        checksController.checkFirstSeen().catchError((e, stack) {
          SentryService.captureError(
            exception: e,
            stackTrace: stack,
            functionName: '_initializeSharedPreferences (Checks)',
            fileName: 'fawri_main.dart',
            lineNumber: 137,
          );
          throw e;
        }),
        cartController.checkFirstSeen().catchError((e, stack) {
          SentryService.captureError(
            exception: e,
            stackTrace: stack,
            functionName: '_initializeSharedPreferences (Cart)',
            fileName: 'fawri_main.dart',
            lineNumber: 147,
          );
          throw e;
        }),
      ]);
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: '_initializeSharedPreferences',
        fileName: 'fawri_main.dart',
        lineNumber: 109,
      );
      // Don't rethrow - allow app to continue with default values
    }
  }

  /// Initialize data from database in parallel
  Future<void> initializeDataFromDatabase({
    required CartController cartController,
    required FavouriteController favouriteController,
    required NotificationController notificationController,
  }) async {
    try {
      await Future.wait<void>([
        cartController.getCartItems().catchError((e, stack) {
          SentryService.captureError(
            exception: e,
            stackTrace: stack,
            functionName: '_initializeDataFromDatabase (Cart)',
            fileName: 'fawri_main.dart',
            lineNumber: 176,
          );
          throw e;
        }),
        favouriteController.getFavouriteItems().catchError((e, stack) {
          SentryService.captureError(
            exception: e,
            stackTrace: stack,
            functionName: '_initializeDataFromDatabase (Favourite)',
            fileName: 'fawri_main.dart',
            lineNumber: 186,
          );
          throw e;
        }),
        notificationController.initializeNotificationStatus().catchError((e, stack) {
          SentryService.captureError(
            exception: e,
            stackTrace: stack,
            functionName: '_initializeDataFromDatabase (Notification)',
            fileName: 'fawri_main.dart',
            lineNumber: 196,
          );
          throw e;
        }),
      ]);
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: '_initializeDataFromDatabase',
        fileName: 'fawri_main.dart',
        lineNumber: 168,
      );
      // Don't rethrow - allow app to continue with empty data
    }
  }

  /// Schedule cart reminder notifications if needed
  Future<void> scheduleNotificationsIfNeeded({
    required NotificationController notificationController,
    required CartController cartController,
  }) async {
    try {
      if (notificationController.notificationsEnabled) {
        await NotificationService.scheduleCartReminderIfNeeded(
          cartItemCount: cartController.cartItems.length,
        );
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: '_scheduleNotificationsIfNeeded',
        fileName: 'fawri_main.dart',
        lineNumber: 219,
      );
      // Don't rethrow - allow app to continue without scheduled notifications
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GamesCubit(getIt.get<AudioHelper>()),
        ),
        BlocProvider(
          create: (context) {
            final cubit = InternetCubit();
            cubit.checkConnection(); // Start monitoring here
            return cubit;
          },
        ),
      ],
      child: BlocBuilder<InternetCubit, InternetState>(
        builder: (context, state) {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            fontSizeResolver: FontSizeResolvers.height,
            ensureScreenSize: true,
            splitScreenMode: true,
            minTextAdapt: true,
            enableScaleWH: () => true,
            enableScaleText: () => true,
            builder: (_, child) {
              return MaterialApp(
                navigatorKey: NavigatorApp.navigatorKey,
                navigatorObservers: [
                  FirebaseAnalyticsObserver(analytics: analytics),
                ],
                scaffoldMessengerKey: rootScaffoldMessengerKey,
                debugShowCheckedModeBanner: false,
                initialRoute: AppRoutes.splash,
                onGenerateRoute: (settings) {
                  final builder = listRoute[settings.name];
                  if (builder != null) {
                    return MaterialPageRoute(
                      builder: (context) => builder(context, settings.arguments),
                      settings: settings,
                    );
                  }
                  return null;
                },
                title: 'Fawri',
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('ar'),
                ],
                locale: const Locale("ar"),
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
                  useMaterial3: true,
                  shadowColor: Colors.white,
                  textTheme:
                      GoogleFonts.tajawalTextTheme(Theme.of(context).textTheme),
                  dialogTheme: const DialogThemeData(
                    backgroundColor: Colors.white,
                  ),
                ),
                builder: (context, widget) {
                  return BlocListener<InternetCubit, InternetState>(
                    listener: (context, state) async {
                      try {
                        if (state is NotConnectedState && !isDialogShowing) {
                          isDialogShowing = true;
                          await NoConnection.show();
                        }

                        if (state is ConnectedState && isDialogShowing) {
                          Navigator.of(
                                  NavigatorApp.navigatorKey.currentState!
                                      .overlay!.context,
                                  rootNavigator: true)
                              .pop();

                          isDialogShowing = false;
                        }
                      } catch (e, stack) {
                        await SentryService.captureError(
                          exception: e,
                          stackTrace: stack,
                          functionName: 'listener',
                          fileName: 'fawri_main.dart',
                          lineNumber: 120,
                        );
                      }
                    },
                    child: widget!,
                  );
                },
                home: child,
              );
            },
          );
        },
      ),
    );
  }
}
