import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vibration/vibration.dart';
import '../../controllers/user_controller.dart';
import '../../core/dialogs/dialog_waiting/dialog_waiting.dart';
import '../../core/utilities/style/text_style.dart';
import '../../core/widgets/background_login_screen.dart';
import '../../core/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    UserController userController = context.watch<UserController>();
    return BackgroundLoginScreen(
      widget: Padding(
        padding:
            EdgeInsets.only(left: 8.w, right: 8.w, top: 12.h, bottom: 130.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BouncingWidget(
                      child: CustomButtonWithoutIcon(
                    text: "اكتشف الفرص !",
                    textWaiting: "قيد الإنتظار ...",
                    loadingButton: userController.isLoading,
                    onPressed: () async {
                      Vibration.vibrate(duration: 100);
                      userController.changeLoading();
                      userController.addUser();
                    },
                  )),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                          color: Colors.white,
                          height: 1.h,
                          width: double.maxFinite,
                        )),
                        Text(" OR ",
                            style: CustomTextStyle()
                                .heading1L
                                .copyWith(fontSize: 13.sp)),
                        Expanded(
                            child: Container(
                          color: Colors.white,
                          height: 1.h,
                          width: double.maxFinite,
                        )),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BouncingWidget(
                        child: IconSvg(
                          onPressed: () async {
                            dialogWaiting();
                            await userController.signInWithGoogle();
                          },
                          nameIcon: Assets.icons.email,
                          colorFilter:
                              ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }
}
