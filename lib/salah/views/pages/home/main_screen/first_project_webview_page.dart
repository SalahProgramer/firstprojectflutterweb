import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../widgets/app_bar_widgets/app_bar_custom.dart';

class FirstProjectWebViewPage extends StatefulWidget {
  const FirstProjectWebViewPage({super.key});

  @override
  State<FirstProjectWebViewPage> createState() => _FirstProjectWebViewPageState();
}

class _FirstProjectWebViewPageState extends State<FirstProjectWebViewPage> {
  bool _isLoading = true;
  static const String url = 'https://firstprojectflutterweb.vercel.app/';

  void _handleLoadFinished() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "First Project",
        textButton: "رجوع",
        onPressed: () async {
          Navigator.of(context).maybePop();
        },
        actions: [],
        colorWidgets: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InAppWebView(
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  allowsInlineMediaPlayback: true,
                  useShouldOverrideUrlLoading: true,
                  useHybridComposition: true,
                ),
                initialUrlRequest: URLRequest(url: WebUri(url)),
                onLoadStop: (_, __) => _handleLoadFinished(),
                onLoadError: (_, __, ___, ____) => _handleLoadFinished(),
                onLoadHttpError: (_, __, ___, ____) => _handleLoadFinished(),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.white70,
                    child: Center(
                      child: SpinKitThreeBounce(
                        color: Colors.black,
                        size: 25.w,
                      ),
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
