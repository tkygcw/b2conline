import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'domain.dart';
import 'notification/notification.dart';
import 'notification/notification_plugin.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// ignore: must_be_immutable
class WebView extends StatefulWidget {
  WebView({super.key, required this.path});

  String path;

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController _controller;
  bool isLoading = false;
  bool canGoBack = false;

  @override
  void initState() {
    super.initState();
    launchChecking();
    initializeWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (canGoBack) {
            _controller.goBack();
            return false;
          }
          return true;
        },
        child: SafeArea(
            child: Stack(
          children: [
            WebViewWidget(
              controller: _controller,
            ),
            if (isLoading)
              Container(
                color: Colors.transparent,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        )),
      ),
    );
  }

  setupNotificationChannel(List data) {
    List<CustomNotificationChannel> channels = [];
    channels.addAll(data.map((jsonObject) => CustomNotificationChannel.fromJson(jsonObject)).toList());
    NotificationPlugin().createChannel(channels);
  }

  void launchChecking() async {
    Map data = await Domain().launchCheck();
    if (data['status'] == '1') {
      //setup notification channels
      if (!kIsWeb) setupNotificationChannel(data['notification_channel']);
    } else {}
  }

  void initializeWebView() {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..goBack()
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });

            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            isLoading = false;
            controller.canGoBack().then((value) {
              canGoBack = value;
            });

            setState(() {});
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                        ''');
          },
          onUrlChange: (UrlChange change) async {
            if (!change.url!.startsWith(Domain.url)) {
              await launchUrl(Uri.parse(change.url!),
                  mode: !kIsWeb && Platform.isIOS ? LaunchMode.externalNonBrowserApplication : LaunchMode.externalNonBrowserApplication);
              //_launchUrl(Uri.parse(change.url!));
              controller.loadRequest(Uri.parse(Domain.url));
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.path));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }
}
