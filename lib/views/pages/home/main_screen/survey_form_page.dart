import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/widgets/app_bar_widgets/app_bar_custom.dart';

class SurveyFormPage extends StatefulWidget {
  const SurveyFormPage({super.key, required this.url});

  final String url;

  @override
  State<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  bool _isLoading = true;

  void _handleLoadFinished() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      CustomAppBar(
        title: "شركاء النجاح",
        textButton: "رجوع",
        onPressed: () async {
          Navigator.of(context).maybePop();
        },
        
        actions: [],

        colorWidgets: Colors.white,
      )
  ,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InAppWebView(
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  allowsInlineMediaPlayback: true,
                ),
                initialUrlRequest: URLRequest(
                  url: WebUri(widget.url),
                ),
                onLoadStop: (_, __) => _handleLoadFinished(),
                onLoadError: (_, __, ___, ____) => _handleLoadFinished(),
                onLoadHttpError: (_, __, ___, ____) => _handleLoadFinished(),
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

