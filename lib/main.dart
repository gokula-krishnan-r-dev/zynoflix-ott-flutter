import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:io' show Platform;
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// App configuration for easy customization
class AppConfig {
  static const String appName = 'ShortFilm OTT';
  static const String logoPath = 'assets/images/play_store_512.png';
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
  
  const ZynoFlixLogo({
    Key? key, 
    this.size = 120, 
    this.showText = true,
  }) : super(key: key);
  
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
            child: Image.asset(AppConfig.logoPath, width: 300, height: 300),
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
                child: Image.asset(AppConfig.logoPath),
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
    final Paint paint = Paint()
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
      size.width * 0.85, size.height * 0.5, 
      size.width * 0.7, size.height * 0.6
    );
    
    // Line to bottom-left
    trianglePath.lineTo(size.width * 0.35 + radius, size.height * 0.8);
    
    // Rounded corner at bottom-left
    trianglePath.quadraticBezierTo(
      size.width * 0.35, size.height * 0.8,
      size.width * 0.35, size.height * 0.8 - radius
    );
    
    // Line back to start, with rounded corner at top-left
    trianglePath.lineTo(size.width * 0.35, size.height * 0.2 + radius);
    trianglePath.quadraticBezierTo(
      size.width * 0.35, size.height * 0.2,
      size.width * 0.35 + radius, size.height * 0.2
    );
    
    canvas.drawPath(trianglePath, paint);
    
    // Draw the pixel fragments (squares that trail behind the triangle)
    final Paint pixelPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw pixel squares in a pattern similar to the image
    _drawPixel(canvas, pixelPaint, size.width * 0.2, size.height * 0.4, size.width * 0.08);
    _drawPixel(canvas, pixelPaint, size.width * 0.15, size.height * 0.5, size.width * 0.06);
    _drawPixel(canvas, pixelPaint, size.width * 0.25, size.height * 0.6, size.width * 0.07);
    _drawPixel(canvas, pixelPaint, size.width * 0.18, size.height * 0.7, size.width * 0.05);
    _drawPixel(canvas, pixelPaint, size.width * 0.12, size.height * 0.35, size.width * 0.04);
    
    // Draw white highlights on the triangle to give it dimension
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final Path highlightPath = Path()
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize WebView platform based on platform
  if (!kIsWeb) { // Not running on web
    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else if (Platform.isIOS) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }
  }
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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
  const MyApp({Key? key, required this.title}) : super(key: key);

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
            return SplashScreen(
              title: title, 
              logoImage: snapshot.data,
            );
          }
          // Show a simple loading screen while loading the logo
          return Scaffold(
            backgroundColor: AppConfig.primaryColor,
            body: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key, 
    required this.title, 
    this.logoImage,
  }) : super(key: key);

  final String title;
  final ui.Image? logoImage;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _controller.forward();
    
    Timer(AppConfig.splashDuration, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => WebViewPage(
              title: widget.title,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var slideAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ));
              
              var fadeAnimation = Tween<double>(
                begin: 0.0, 
                end: 1.0
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ));
              
              return SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 700),
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
    final deviceSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppConfig.backgroundColor,
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                
                // Logo and text
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Hero(
                          tag: 'app_logo',
                          child: ZynoFlixLogo(
                            size: deviceSize.width * 0.35,
                            showText: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(flex: 2),
                
                // Watch Now button
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => WebViewPage(title: widget.title),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'WATCH NOW',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppConfig.textColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: AppConfig.textColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Animated wave at bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _waveAnimation.value,
                        child: SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: WavePainter(
                              animationValue: _waveAnimation.value,
                              color: AppConfig.primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Loading indicator (only visible during initial loading)
          if (!_controller.isCompleted)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: AppConfig.secondaryColor,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
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
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final double waveHeight = size.height * 0.8;
    final double waveWidth = size.width;
    
    final Path path = Path();
    path.moveTo(0, size.height);
    
    // Create the wave effect with multiple sine waves
    for (int i = 0; i < waveWidth.toInt(); i++) {
      final double x = i.toDouble();
      final double y = sin((x * 0.015) + (animationValue * 10)) * (waveHeight * 0.3) +
                      sin((x * 0.03) + (animationValue * 5)) * (waveHeight * 0.2) +
                      size.height - waveHeight;
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
  const WebViewPage({
    Key? key, 
    required this.title,
    this.logoImage,
  }) : super(key: key);

  final String title;
  final ui.Image? logoImage;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController? _controller;
  bool isLoading = true;
  bool hasError = false;
  String currentUrl = AppConfig.webUrl;
  double loadingProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initWebView();
    } else {
      // On web, we'll display a message instead of using WebView
      isLoading = false;
    }
  }
  
  void _initWebView() {
    // Create platform-specific controller params
    late final PlatformWebViewControllerCreationParams params;
    
    // Check if we're running on web
    if (Platform.isAndroid) {
      params = AndroidWebViewControllerCreationParams();
    } else if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    
    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppConfig.backgroundColor)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingProgress = progress / 100;
              if (progress == 100) {
                isLoading = false;
              }
            });
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              hasError = false;
              currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
              currentUrl = url;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame == true) {
              setState(() {
                hasError = true;
                isLoading = false;
              });
              debugPrint('Web resource error: ${error.description}');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // You can add URL filtering logic here if needed
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConfig.webUrl));
    
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!kIsWeb && _controller != null && await _controller!.canGoBack()) {
          _controller!.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            if (!kIsWeb && _controller != null)
              Padding(padding: const EdgeInsets.only(top: 16), child: 
                WebViewWidget(controller: _controller!),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppConfig.logoPath, width: 100, height: 100),
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
                     Image.asset(AppConfig.logoPath, width: 100, height: 100),
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
                      Image.asset(AppConfig.logoPath, width: 100, height: 100),
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
                          _controller?.reload();
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
}