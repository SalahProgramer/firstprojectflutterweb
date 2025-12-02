import 'package:fawri_app_refactor/controllers/page_main_screen_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/firebase/user/user_controller.dart';
import '../core/firebase/user/user_model.dart';
import '../core/services/database/address/local_storage.dart';
import '../core/services/sentry/sentry_service.dart';
import '../core/utilities/global/app_global.dart';
import '../core/utilities/routes.dart';
import 'custom_page_controller.dart';

class UserController extends ChangeNotifier {
  bool isLoading = false;
  final UserService userService = UserService();
  bool isSelectedSize = false;
  bool showCaseShown = false;
  String userId = "";

  UserItem? user;
  Map sizes = {};
  String sizesOutput = "";

  PageMainScreenController pageMainScreenController =
      NavigatorApp.context.read<PageMainScreenController>();
  CustomPageController customPageController =
      NavigatorApp.context.read<CustomPageController>();

  Future<void> setSizesArray({required String mainCategory}) async {
    if (mainCategory == "ملابس نسائيه") {
      sizes = LocalStorage().getSize("womenSizes");
    } else if (mainCategory == "ملابس رجاليه") {
      sizes = LocalStorage().getSize("menSizes");
    } else if (mainCategory == "ملابس نسائيه مقاس كبير") {
      sizes = LocalStorage().getSize("womenPlusSizes");
    } else if (mainCategory == "مستلزمات اعراس") {
      sizes = LocalStorage().getSize("Weddings & Events");
    } else if (mainCategory == "ملابس داخليه") {
      sizes = LocalStorage().getSize("Underwear_Sleepwear_sizes");
    }
    List trueSizes = (sizes)
        .entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    sizesOutput = trueSizes.join(', ');
    notifyListeners();
  }

  Future<void> hasShowcaseBeenShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showCaseShown = prefs.getBool('showcaseShown') ?? false;
    notifyListeners();
  }

  // Function to mark the showcase as shown
  Future<void> markShowcaseAsShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showCaseShown = await prefs.setBool('showcaseShown', true);
    notifyListeners();
  }

  Future<void> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('user_id') ?? "";
    userId = userID;
    notifyListeners();
  }

  Future<void> getSelectedSizeAndUserIDAndShowCaseShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('user_id') ?? "";
    showCaseShown = prefs.getBool('showcaseShown') ?? false;
    bool isSelectedSizeShared = prefs.getBool('is_selected_size') ?? false;
    userId = userID;
    isSelectedSize = isSelectedSizeShared;
    notifyListeners();
  }

  void changeLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    var data = await FirebaseAuth.instance.signInWithCredential(credential);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('device_token');
    userId = Uuid().v4();
    user = UserItem(
      name: "",
      id: userId,
      token: token.toString(),
      email: data.user!.email.toString(),
      password: "",
      address: 'address',
      birthdate: '',
      area: '',
      gender: '',
      city: '',
      phone: '',
    );
    userService.addUser(user!).then((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setBool('login', true);
      await customPageController.changeIndexPage(0);
      await customPageController.changeIndexCategoryPage(1);
      NavigatorApp.navigateToRemoveUntil(AppRoutes.pages);
    }).catchError((error, stack) async {
      await SentryService.captureError(exception: error, stackTrace: stack);
      Fluttertoast.showToast(msg: "حدث خطأ ما , الرجاء المحاوله فيما بعد");
    });

    notifyListeners();

    // Once signed in, return the UserCredential
    return data;
  }

  // signInWithFacebook() async {
  //   try {
  //     final LoginResult loginResult = await FacebookAuth.instance
  //         .login(permissions: ['email', 'public_profile', 'user_birthday']);
  //     final OAuthCredential facebookAuthCredential =
  //         FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
  //     var userDate = await FacebookAuth.instance.getUserData();
  //     // String userDataJson = json.encode(userDate);
  //     userId = Uuid().v4();
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString('device_token');
  //     UserItem newItem = UserItem(
  //       name: "",
  //       id: userId,
  //       token: token.toString(),
  //       email: userDate["email"],
  //       password: "",
  //       birthdate: '',
  //       address: '',
  //       gender: '',
  //       area: '',
  //       city: '',
  //       phone: '',
  //     );
  //     userService.addUser(newItem).then((_) async {
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('user_id', userId);
  //       await prefs.setBool('login', true);
  //       NavigatorApp.push(Pages());
  //     }).catchError((error) {
  //       NavigatorApp.pop();
  //       Fluttertoast.showToast(msg: "حدث خطأ ما , الرجاء المحاوله فيما بعد");
  //     });
  //
  //     // Try to sign in with Facebook credential
  //     await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'account-exists-with-different-credential') {
  //       // Handle account linking here
  //       // Get the email address of the user.
  //       String email = e.email!;
  //
  //       // Fetch sign-in methods for the email.
  //       List<String> methods =
  //           await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
  //
  //       // Check if the user has already signed in using a different provider.
  //       if (methods.contains('password')) {
  //         // User already signed in with email/password, show error or handle accordingly.
  //         Fluttertoast.showToast(
  //             msg: "You have already signed in with email/password.");
  //       } else {
  //         // User signed in with a different provider, link the accounts.
  //         // Retrieve current user and link the Facebook credential.
  //         User? currentUser = FirebaseAuth.instance.currentUser;
  //         if (currentUser != null) {
  //           // Retrieve loginResult here
  //           final LoginResult loginResult = await FacebookAuth.instance.login(
  //               permissions: ['email', 'public_profile', 'user_birthday']);
  //           final OAuthCredential facebookAuthCredential =
  //               FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
  //           await currentUser.linkWithCredential(facebookAuthCredential);
  //           // Continue with your application flow after linking the accounts.
  //         }
  //       }
  //     } else {
  //       NavigatorApp.pop();
  //       Fluttertoast.showToast(msg: "حدث خطأ ما , الرجاء المحاوله فيما بعد");
  //     }
  //   } catch (e) {
  //     NavigatorApp.pop();
  //     Fluttertoast.showToast(msg: "حدث خطأ ما , الرجاء المحاوله فيما بعد");
  //   }
  // }

  addUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('device_token');
    userId = Uuid().v4();

    user = UserItem(
      name: "",
      id: userId,
      token: token.toString(),
      email: "$userId@gmail.com",
      password: "",
      address: '',
      birthdate: '',
      gender: '',
      area: '',
      city: '',
      phone: '',
    );
    userService.addUser(user!).then((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setBool('login', true);

      await customPageController.changeIndexPage(0);
      await customPageController.changeIndexCategoryPage(1);
      notifyListeners();
      NavigatorApp.navigateToRemoveUntil(AppRoutes.pages);
      await Future.delayed(Duration(seconds: 2));
      changeLoading();
    }).catchError((error, stack) async {
      changeLoading();
      await SentryService.captureError(
        exception: error,
        stackTrace: stack,
        functionName: 'addUser',
        fileName: 'user_controller.dart',
        lineNumber: 240,
      );
    });
  }
}
