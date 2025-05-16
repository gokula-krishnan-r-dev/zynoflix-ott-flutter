import 'package:flutter/material.dart';
import '../config/app_config.dart';

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
                  color: AppConfig.primaryColor.withValues(alpha: 102),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(AppConfig.newLogoPath, width: 400, height: 400),
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
                      color: AppConfig.textColor.withValues(alpha: 204),
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
                      color: AppConfig.primaryColor.withValues(alpha: 102),
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
