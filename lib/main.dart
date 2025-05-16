import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:math';

// App configuration for easy customization
class AppConfig {
  static const String appName = 'ShortFilm OTT';
  static const String logoPath = 'assets/images/newlogo.png';
  static const String newLogoPath = 'assets/images/newlogo.png';
  static const String webUrl = 'https://zynoflixott.com';
  static const Duration splashDuration = Duration(seconds: 3);

  // Updated colors to match the ShortFilm OTT image
  static const Color primaryColor = Color(0xFF8028E6); // Purple from logo
  static const Color secondaryColor = Color(0xFF4C73FF); // Blue accent
  static const Color backgroundColor = Color(0xFF0A0A10); // Dark background
  static const Color textColor = Colors.white;
  static const Color goldColor = Color(0xFFFFD700); // Gold for star
}

// Logo widget for consistent logo display
class ZynoFlixLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const ZynoFlixLogo({super.key, this.size = 120, this.showText = true});

  @override
  Widget build(BuildContext context) {
    // Adjust size based on device width to ensure proper scaling
    final screenWidth = MediaQuery.of(context).size.width;
    final adjustedSize = screenWidth < 600 ? size * 0.8 : size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image with glow effect
        if (!showText)
          Container(
            height: adjustedSize,
            width: adjustedSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppConfig.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(AppConfig.logoPath, width: 400, height: 400),
          ),

        // Logo text
        if (showText)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ShortFilm text
              Text(
                'ShortFilm',
                style: TextStyle(
                  fontSize: adjustedSize * 0.35,
                  fontWeight: FontWeight.bold,
                  height: 0.9,
                  letterSpacing: 1.0,
                  color: AppConfig.textColor,
                ),
              ),

              // OTT with star
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'OTT',
                    style: TextStyle(
                      fontSize: adjustedSize * 0.5,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      letterSpacing: 2.0,
                      color: AppConfig.textColor,
                    ),
                  ),
                  SizedBox(width: adjustedSize * 0.05),
                  Icon(
                    Icons.star,
                    color: AppConfig.goldColor,
                    size: adjustedSize * 0.3,
                  ),
                ],
              ),

              // Website URL - show only on larger screens
              if (adjustedSize > 80 && screenWidth > 400)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'WWW.ZYNOFLIXOTT.COM',
                    style: TextStyle(
                      fontSize: adjustedSize * 0.1,
                      letterSpacing: 1.2,
                      color: AppConfig.textColor.withOpacity(0.8),
                    ),
                  ),
                ),

              // Space before play logo
              SizedBox(height: adjustedSize * 0.3),

              // Play logo
              Container(
                height: adjustedSize * 0.45,
                width: adjustedSize * 0.45,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppConfig.primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(AppConfig.newLogoPath),
              ),
            ],
          ),
      ],
    );
  }
}

// Custom painter for the play button logo
class PlayButtonPainter extends CustomPainter {
  final Color color;

  PlayButtonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Draw the main play triangle shape with rounded corners
    final Path trianglePath = Path();

    // Create a rounded triangle shape
    final double radius = size.width * 0.1;

    // Starting point (top-left with rounded corner)
    trianglePath.moveTo(size.width * 0.35 + radius, size.height * 0.2);

    // Line to top-right corner
    trianglePath.lineTo(size.width * 0.7, size.height * 0.4);

    // Round the corner at the right-middle point
    trianglePath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.6,
    );

    // Line to bottom-left
    trianglePath.lineTo(size.width * 0.35 + radius, size.height * 0.8);

    // Rounded corner at bottom-left
    trianglePath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.8,
      size.width * 0.35,
      size.height * 0.8 - radius,
    );

    // Line back to start, with rounded corner at top-left
    trianglePath.lineTo(size.width * 0.35, size.height * 0.2 + radius);
    trianglePath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.2,
      size.width * 0.35 + radius,
      size.height * 0.2,
    );

    canvas.drawPath(trianglePath, paint);

    // Draw the pixel fragments (squares that trail behind the triangle)
    final Paint pixelPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Draw pixel squares in a pattern similar to the image
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.08,
    );
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.15,
      size.height * 0.5,
      size.width * 0.06,
    );
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.25,
      size.height * 0.6,
      size.width * 0.07,
    );
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.18,
      size.height * 0.7,
      size.width * 0.05,
    );
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.12,
      size.height * 0.35,
      size.width * 0.04,
    );

    // Draw white highlights on the triangle to give it dimension
    final Paint highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final Path highlightPath =
        Path()
          ..moveTo(size.width * 0.4, size.height * 0.3)
          ..lineTo(size.width * 0.6, size.height * 0.4)
          ..lineTo(size.width * 0.55, size.height * 0.45)
          ..lineTo(size.width * 0.38, size.height * 0.37)
          ..close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawPixel(Canvas canvas, Paint paint, double x, double y, double size) {
    // Round the corners of the pixels slightly
    final RRect pixelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, size, size),
      Radius.circular(size * 0.2),
    );
    canvas.drawRRect(pixelRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Service to preload and cache assets
class AssetService {
  static Future<ui.Image?> loadLogoImage() async {
    try {
      final ByteData data = await rootBundle.load(AppConfig.logoPath);
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
        completer.complete(img);
      });
      return completer.future;
    } catch (e) {
      debugPrint('Failed to load logo: $e');
      return null;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConfig.primaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp(title: AppConfig.appName));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.primaryColor,
          brightness: Brightness.dark,
          background: AppConfig.backgroundColor,
          primary: AppConfig.primaryColor,
          secondary: AppConfig.secondaryColor,
        ),
        scaffoldBackgroundColor: AppConfig.backgroundColor,
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: false,
          backgroundColor: AppConfig.backgroundColor,
          foregroundColor: AppConfig.textColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.secondaryColor,
            foregroundColor: AppConfig.textColor,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.primaryColor,
          brightness: Brightness.dark,
          background: AppConfig.backgroundColor,
          primary: AppConfig.primaryColor,
          secondary: AppConfig.secondaryColor,
        ),
        scaffoldBackgroundColor: AppConfig.backgroundColor,
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: false,
          backgroundColor: AppConfig.backgroundColor,
          foregroundColor: AppConfig.textColor,
        ),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<ui.Image?>(
        future: AssetService.loadLogoImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Pass the preloaded image to the splash screen
            return SplashScreen(title: title, logoImage: snapshot.data);
          }
          // Show a simple loading screen while loading the logo
          return Scaffold(
            backgroundColor: AppConfig.primaryColor,
            body: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title, this.logoImage});

  final String title;
  final ui.Image? logoImage;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Navigate to the main screen after the splash animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(title: widget.title),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/images/newlogo.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}

// Custom wave painter
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final double waveHeight = size.height * 0.8;
    final double waveWidth = size.width;

    final Path path = Path();
    path.moveTo(0, size.height);

    // Create the wave effect with multiple sine waves
    for (int i = 0; i < waveWidth.toInt(); i++) {
      final double x = i.toDouble();
      final double y =
          sin((x * 0.015) + (animationValue * 10)) * (waveHeight * 0.3) +
          sin((x * 0.03) + (animationValue * 5)) * (waveHeight * 0.2) +
          size.height -
          waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.title, this.logoImage});

  final String title;
  final ui.Image? logoImage;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _webViewController;
  final GlobalKey webViewKey = GlobalKey();
  bool isLoading = true;
  bool hasError = false;
  String currentUrl = AppConfig.webUrl;
  double loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _checkAndRequestPermissions();
    } else {
      // On web, we'll display a message instead of using WebView
      isLoading = false;
    }
  }

  // Comprehensive permission handling for both Android and iOS
  Future<void> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // Android permissions - only request the essential ones
      await [Permission.photos, Permission.camera, Permission.videos].request();

      // Log the permission status but don't show dialog
      Map<Permission, PermissionStatus> statuses = {
        Permission.photos: await Permission.photos.status,
        Permission.camera: await Permission.camera.status,
        Permission.videos: await Permission.videos.status,
      };

      bool allGranted = true;
      String deniedPermissions = '';

      statuses.forEach((permission, status) {
        if (status != PermissionStatus.granted) {
          allGranted = false;
          deniedPermissions += '${permission.toString()}, ';
        }
      });

      if (!allGranted) {
        debugPrint('Some permissions were denied: $deniedPermissions');
      }
    } else if (Platform.isIOS) {
      // iOS permissions - only request the essential ones
      await [
        Permission.photos,
        Permission.camera,
        Permission.mediaLibrary,
      ].request();

      // Log the permission status but don't show dialog
      Map<Permission, PermissionStatus> statuses = {
        Permission.photos: await Permission.photos.status,
        Permission.camera: await Permission.camera.status,
        Permission.mediaLibrary: await Permission.mediaLibrary.status,
      };

      bool allGranted = true;
      String deniedPermissions = '';

      statuses.forEach((permission, status) {
        if (status != PermissionStatus.granted) {
          allGranted = false;
          deniedPermissions += '${permission.toString()}, ';
        }
      });

      if (!allGranted) {
        debugPrint('Some iOS permissions were denied: $deniedPermissions');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!kIsWeb && _webViewController != null) {
          if (await _webViewController!.canGoBack()) {
            _webViewController!.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            if (!kIsWeb)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                      url: WebUri(AppConfig.webUrl),
                    ),
                    initialSettings: InAppWebViewSettings(
                      mediaPlaybackRequiresUserGesture: false,
                      javaScriptEnabled: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      supportZoom: true,
                      useShouldOverrideUrlLoading: true,
                      allowFileAccessFromFileURLs: true,
                      allowUniversalAccessFromFileURLs: true,
                      useHybridComposition: true,
                      useOnLoadResource: true,
                      supportMultipleWindows: true,
                      verticalScrollBarEnabled: true,
                      horizontalScrollBarEnabled: true,
                      preferredContentMode:
                          UserPreferredContentMode.RECOMMENDED,
                      applicationNameForUserAgent: "ShortFilm-OTT-App",
                      allowsInlineMediaPlayback: true,
                      useShouldInterceptRequest: true,
                      useShouldInterceptAjaxRequest: true,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      // Inject JavaScript to enhance form data logging
                      _injectFormDataLogger(controller);
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        isLoading = true;
                        hasError = false;
                        currentUrl = url?.toString() ?? '';
                      });
                    },
                    onLoadStop: (controller, url) {
                      setState(() {
                        isLoading = false;
                        currentUrl = url?.toString() ?? '';
                      });

                      // Reinject script on each page load to ensure it's available
                      _injectFormDataLogger(controller);
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        loadingProgress = progress / 100;
                        if (progress == 100) {
                          isLoading = false;
                        }
                      });
                    },
                    shouldOverrideUrlLoading: (
                      controller,
                      navigationAction,
                    ) async {
                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadError: (controller, url, code, message) {
                      setState(() {
                        hasError = true;
                        isLoading = false;
                      });
                      debugPrint('WebView error: $message');
                    },
                    onLoadHttpError: (
                      controller,
                      url,
                      statusCode,
                      description,
                    ) {
                      setState(() {
                        hasError = statusCode >= 400;
                        isLoading = false;
                      });
                      debugPrint('HTTP error: $statusCode $description');
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      debugPrint('Console: ${consoleMessage.message}');

                      // Check if a video is playing
                      if (consoleMessage.message.contains('Video is playing')) {
                        // You can add video-specific handling here
                        debugPrint('Video playback detected');
                      }
                    },
                    onLoadResource: (controller, resource) {
                      // Check if the loaded resource is a video file
                      if (resource.url.toString().contains('.mp4') ||
                          resource.url.toString().contains('.m3u8') ||
                          resource.url.toString().contains('.webm')) {
                        debugPrint('Video resource detected: ${resource.url}');
                      }
                    },
                    // Handle entering and exiting fullscreen mode
                    onEnterFullscreen: (controller) {
                      debugPrint('Entering fullscreen mode');
                      // Force landscape orientation when entering fullscreen
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    },
                    onExitFullscreen: (controller) {
                      debugPrint('Exiting fullscreen mode');
                      // Allow all orientations when exiting fullscreen
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    },
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppConfig.newLogoPath),
                    const SizedBox(height: 40),
                    Text(
                      'ShortFilm OTT',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'For the best experience, please visit ${AppConfig.webUrl} directly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppConfig.textColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // This is a placeholder as we can't launch URLs directly on web from web
                      },
                      child: const Text('Visit Website'),
                    ),
                  ],
                ),
              ),
            if (isLoading && !kIsWeb)
              Container(
                color: AppConfig.backgroundColor.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Show logo while loading
                      Image.asset(
                        AppConfig.newLogoPath,
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 40),
                      CircularProgressIndicator(
                        value: loadingProgress > 0 ? loadingProgress : null,
                        color: AppConfig.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading... ${(loadingProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: AppConfig.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (hasError && !kIsWeb)
              Container(
                color: AppConfig.backgroundColor,
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Also show logo in error screen
                      Image.asset(
                        AppConfig.newLogoPath,
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 32),
                      Icon(
                        Icons.error_outline,
                        color: AppConfig.secondaryColor,
                        size: 60,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Connection Error',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to connect to the website. Please check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            hasError = false;
                            isLoading = true;
                          });
                          _webViewController?.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Inject JavaScript to better handle form submissions and logging
  void _injectFormDataLogger(InAppWebViewController controller) {
    controller.evaluateJavascript(
      source: '''
      (function() {
        // Avoid injecting multiple times
        if (window.formDataLoggerInjected) return;
        window.formDataLoggerInjected = true;
        
        console.log("Form data logger injected");
        
        // Make videos fullscreen-friendly
        function setupVideoFullscreenSupport() {
          // Find all video elements on the page
          const videos = document.querySelectorAll('video');
          videos.forEach(video => {
            if (!video.hasAttribute('data-fullscreen-enabled')) {
              // Mark this video as enhanced
              video.setAttribute('data-fullscreen-enabled', 'true');
              
              // Add fullscreen capability
              video.setAttribute('playsinline', 'true');
              video.setAttribute('webkit-playsinline', 'true');
              video.setAttribute('controls', 'true');
              
              // Make sure clicking the video works for fullscreen
              video.addEventListener('click', function() {
                if (this.paused) {
                  this.play();
                }
              });
              
              // Add double tap for fullscreen
              let lastTapTime = 0;
              video.addEventListener('touchend', function(e) {
                const currentTime = new Date().getTime();
                const tapLength = currentTime - lastTapTime;
                if (tapLength < 300 && tapLength > 0) {
                  // Double tap detected
                  e.preventDefault();
                  if (document.fullscreenElement) {
                    document.exitFullscreen();
                  } else {
                    if (this.requestFullscreen) {
                      this.requestFullscreen();
                    } else if (this.webkitRequestFullscreen) {
                      this.webkitRequestFullscreen();
                    } else if (this.mozRequestFullScreen) {
                      this.mozRequestFullScreen();
                    } else if (this.msRequestFullscreen) {
                      this.msRequestFullscreen();
                    }
                  }
                }
                lastTapTime = currentTime;
              });
              
              console.log("Enhanced video for fullscreen:", video.src);
            }
          });
        }
        
        // Run immediately and on DOM changes
        setupVideoFullscreenSupport();
        
        // Monitor DOM for new video elements
        const observer = new MutationObserver(function(mutations) {
          setupVideoFullscreenSupport();
        });
        
        observer.observe(document.body, { 
          childList: true, 
          subtree: true 
        });
        
        console.log("Video fullscreen support initialized");
      })();
    ''',
    );
  }
}
