# 🚀 البدء السريع - WebView Setup

## الخطوة الأولى: Firebase (مهمة جداً!)

1. افتح: https://console.firebase.google.com/project/fawri-df598/authentication/settings
2. انزل لـ **Authorized domains**
3. اضغط **Add domain**
4. أضف: `firstprojectflutterweb.vercel.app`
5. احفظ ✅

---

## الخطوة الثانية: رفع التحديثات

```bash
flutter clean
flutter pub get
flutter build web --release
vercel --prod
```

---

## الخطوة الثالثة: كود تطبيق WebView

### في تطبيقك المنفصل، استبدل `main.dart` بـ:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fawri',
      debugShowCheckedModeBanner: false,
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse('https://firstprojectflutterweb.vercel.app/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) 
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
```

---

## الخطوة الرابعة: pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.0.0
```

---

## الخطوة الخامسة: AndroidManifest.xml

في `android/app/src/main/AndroidManifest.xml`، أضف قبل `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## الخطوة السادسة: اختبر!

```bash
flutter run
```

---

## ✅ تم! يجب أن يعمل الآن بدون أخطاء

**إذا لم يعمل، راجع:** `WEBVIEW_SETUP.md` و `CHANGES_SUMMARY.md`

