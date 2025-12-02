# دليل إعداد WebView للتطبيق

## المشاكل التي تم حلها:

### ✅ 1. تحسينات WebView في `web/index.html`
- إضافة viewport meta tag
- تحسين توافق iOS/Android
- منع أخطاء WebGL
- تعطيل Service Worker في WebView

---

## ⚠️ خطوات مطلوبة منك في Firebase Console:

### 🔥 إصلاح مشكلة Firebase OAuth

الخطأ الذي يظهر:
```
The current domain is not authorized for OAuth operations. 
Add your domain (firstprojectflutterweb.vercel.app) to the OAuth redirect domains list
```

**الحل:**

1. **افتح Firebase Console:**
   - اذهب إلى: https://console.firebase.google.com
   - اختر مشروعك: `fawri-df598`

2. **انتقل إلى Authentication:**
   - من القائمة الجانبية → Authentication
   - اختر تبويب **Settings**
   - اضغط على **Authorized domains**

3. **أضف الدومينات التالية:**
   ```
   firstprojectflutterweb.vercel.app
   vercel.app
   *.vercel.app
   ```

4. **احفظ التغييرات**

---

## 📱 الكود الصحيح لتطبيق WebView المنفصل:

### في `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.0.0
  webview_flutter_android: ^3.0.0
  webview_flutter_wkwebview: ^3.0.0
```

### في `main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fawri App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    
    // إنشاء وإعداد WebViewController مع إعدادات محسنة
    late final PlatformWebViewControllerCreationParams params;
    
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    
    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = '';
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'خطأ في تحميل الصفحة: ${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // السماح بالتنقل داخل نفس الدومين
            if (request.url.contains('firstprojectflutterweb.vercel.app')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://firstprojectflutterweb.vercel.app/'));
    
    // إعدادات إضافية للأندرويد
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setGeolocationPermissionsPromptCallbacks(
          onShowPrompt: (request) async {
            return GeolocationPermissionsResponse(
              allow: true,
              retain: true,
            );
          },
        );
    }
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (_errorMessage.isNotEmpty)
                Center(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'خطأ في التحميل',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _errorMessage = '';
                              _isLoading = true;
                            });
                            _controller.loadRequest(
                              Uri.parse('https://firstprojectflutterweb.vercel.app/'),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🔧 إعدادات Android المطلوبة:

### في `android/app/src/main/AndroidManifest.xml`:

أضف الصلاحيات التالية قبل `<application>`:

```xml
<!-- Internet Permission -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- للسماح بـ HTTP (إذا لزم الأمر) -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```

داخل `<application>` أضف:

```xml
<application
    android:usesCleartextTraffic="true"
    android:hardwareAccelerated="true"
    ...>
```

---

## 🍎 إعدادات iOS المطلوبة:

### في `ios/Runner/Info.plist`:

أضف قبل `</dict>`:

```xml
<!-- للسماح بـ HTTP/HTTPS -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<!-- للكاميرا والميكروفون إذا لزم -->
<key>NSCameraUsageDescription</key>
<string>نحتاج للوصول للكاميرا</string>
<key>NSMicrophoneUsageDescription</key>
<string>نحتاج للوصول للميكروفون</string>
```

---

## 📦 بعد التعديلات:

1. **نظف المشروع:**
```bash
flutter clean
flutter pub get
```

2. **أعد بناء الموقع:**
```bash
flutter build web --release
```

3. **ارفع على Vercel:**
```bash
vercel --prod
```

4. **اختبر التطبيق:**
   - شغل تطبيق WebView المنفصل
   - يجب أن يعمل بدون أخطاء WebGL
   - يجب أن تعمل Firebase OAuth بعد إضافة الدومين

---

## 🐛 حل المشاكل الشائعة:

### إذا ظهرت أخطاء WebGL:
- تأكد من أنك رفعت التحديثات على Vercel
- امسح cache المتصفح/WebView

### إذا لم يعمل OAuth:
- تأكد من إضافة الدومين في Firebase Console
- انتظر 5-10 دقائق حتى تنتشر التغييرات

### إذا كان التطبيق بطيء:
- استخدم `--web-renderer canvaskit` عند البناء
- تأكد من تفعيل hardware acceleration

---

## ✅ Checklist:

- [ ] تحديث `web/index.html` (تم)
- [ ] إضافة الدومين في Firebase Console
- [ ] تحديث `AndroidManifest.xml`
- [ ] تحديث `Info.plist` (iOS)
- [ ] إعادة بناء ورفع على Vercel
- [ ] تحديث كود تطبيق WebView
- [ ] اختبار على Android
- [ ] اختبار على iOS

---

**ملاحظة:** إذا استمرت المشاكل، تأكد من:
1. الموقع يعمل بشكل صحيح في المتصفح أولاً
2. تطبيق WebView لديه صلاحيات الإنترنت
3. Firebase Console يحتوي على الدومين الصحيح

