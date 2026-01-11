import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowcaseController extends ChangeNotifier {
  bool showcaseSizeShown = false;
  bool showcaseSortShown = false;
  bool showcaseGameShown = false;
  bool showcaseBottomBarReelsShown =
      false; // Flag for bottom bar reels icon tutorial
  bool showcaseInitialized = false; // Flag to prevent duplicate showcase

  // Initialize from SharedPreferences
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showcaseSizeShown = prefs.getBool('showcaseShown') ?? false;
    showcaseSortShown = prefs.getBool('showcaseShownTwo') ?? false;
    showcaseGameShown =
        // prefs.getBool('showcaseShownThree') ?? false
        true;
    showcaseBottomBarReelsShown =
        prefs.getBool('showcaseBottomBarReelsShown') ?? false;
    showcaseInitialized = false; // Reset on init
    notifyListeners();
  }

  // Mark size showcase as shown
  Future<void> markSizeShowcaseShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showcaseShown', true);
    showcaseSizeShown = true;
    notifyListeners();
  }

  // Mark sort showcase as shown
  Future<void> markSortShowcaseShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showcaseShownTwo', true);
    showcaseSortShown = true;
    notifyListeners();
  }

  // Mark game showcase as shown
  Future<void> markGameShowcaseShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showcaseShownThree', true);
    showcaseGameShown = true;
    showcaseInitialized = true;
    notifyListeners();
  }

  // Mark bottom bar reels showcase as shown
  Future<void> markBottomBarReelsShowcaseShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showcaseBottomBarReelsShown', true);
    showcaseBottomBarReelsShown = true;
    notifyListeners();
  }

  // Reset all showcases (useful for testing or logout)
  Future<void> resetShowcases() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    showcaseSizeShown = false;
    showcaseSortShown = false;
    showcaseGameShown = true;
    showcaseBottomBarReelsShown = false;
    showcaseInitialized = false;
    notifyListeners();
  }
}
