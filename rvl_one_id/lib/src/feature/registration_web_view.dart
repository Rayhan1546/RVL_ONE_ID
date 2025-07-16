// A custom logger or just use debugPrint
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void appLogger(String message) {
  debugPrint('[WebView] $message');
}

class RegistrationWebView extends StatefulWidget {
  final String initialUrl;
  final String targetUrlHostName;
  final Function(String redirectedUrl)? onSuccess;

  const RegistrationWebView({
    super.key,
    required this.initialUrl,
    required this.targetUrlHostName,
    this.onSuccess,
  });

  @override
  State<RegistrationWebView> createState() => _RegistrationWebViewState();
}

class _RegistrationWebViewState extends State<RegistrationWebView> {
  late final WebViewController _webViewController;

  bool _isLoading = true;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    // Load the initial URL provided to the widget
    _webViewController.loadRequest(Uri.parse(widget.initialUrl));
  }

  void _initializeWebView() {
    // --- 1. Create Platform-Specific Parameters ---
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    // --- 2. Initialize the WebViewController ---
    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(_createNavigationDelegate());

    // --- 3. Apply Android-Specific Settings ---
    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  NavigationDelegate _createNavigationDelegate() {
    return NavigationDelegate(
      // --- Handle Loading State ---
      onPageStarted: (String url) {
        appLogger('Page started loading: $url');
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      onProgress: (int progress) {
        appLogger('WebView is loading (progress : $progress%)');
        // You could use this for a progress bar, but for a simple spinner,
        // onPageStarted and onPageFinished are enough.
      },
      onPageFinished: (String url) {
        appLogger('Page finished loading: $url');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      // --- Handle Errors ---
      onWebResourceError: (WebResourceError error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        appLogger(
          'Page resource error: code: ${error.errorCode} '
          'description: ${error.description} '
          'errorType: ${error.errorType} '
          'isForMainFrame: ${error.isForMainFrame}',
        );
      },
      // --- CORE LOGIC: Handle Navigation and Redirects ---
      onNavigationRequest: (NavigationRequest request) {
        appLogger('Attempting to navigate to: ${request.url}');

        // Check if the URL is the target redirect URL
        if (request.url.contains(widget.targetUrlHostName)) {
          // Ensure we only pop once
          if (!_hasPopped) {
            _hasPopped = true;
            appLogger('Target URL detected! Popping screen.');

            // Execute the success callback with the final URL
            widget.onSuccess?.call(request.url);

            // Navigate back to the previous screen
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          }
          // Prevent the webview from navigating to the success URL
          return NavigationDecision.prevent;
        }

        // Allow navigation to standard http/https URLs
        if (request.url.startsWith("http://") ||
            request.url.startsWith("https://")) {
          return NavigationDecision.navigate;
        }

        // Block other protocols (like intent://, mailto:, etc.)
        appLogger('Blocking navigation to non-http URL: ${request.url}');
        return NavigationDecision.prevent;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('One ID Registration')),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
