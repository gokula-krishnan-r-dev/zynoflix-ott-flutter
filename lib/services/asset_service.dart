import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

// Service to preload and cache assets
class AssetService {
  static Future<ui.Image?> loadLogoImage() async {
    try {
      final ByteData data = await rootBundle.load(AppConfig.newLogoPath);
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
