// Renders the app icon / splash source images from the in-app AppLogo, so
// branding always matches the app.
//
//   flutter test tool/branding/render_branding_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// Output: assets/branding/*.png (build-time inputs only, not app assets).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/theme/app_colors.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';
import 'package:habesha_names/app/widgets/app_logo.dart';

/// [logoFraction] of the canvas is the logo; the rest is [background].
Future<void> render(
  WidgetTester t,
  String file, {
  required double size,
  required double logoFraction,
  Color? background,
  bool rounded = false,
}) async {
  final GlobalKey key = GlobalKey();
  t.view.physicalSize = Size(size, size);
  t.view.devicePixelRatio = 1;
  await t.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(AppTranslations.english),
      home: Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: background ?? Colors.transparent,
                borderRadius: rounded
                    ? BorderRadius.circular(size * 0.22)
                    : null,
              ),
              alignment: Alignment.center,
              child: AppLogo(size: size * logoFraction, elevated: false),
            ),
          ),
        ),
      ),
    ),
  );
  await t.runAsync(GoogleFonts.pendingFonts);
  await t.pump();
  await t.runAsync(() async {
    final RenderRepaintBoundary b =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await b.toImage();
    final png = await img.toByteData(format: ui.ImageByteFormat.png);
    File('assets/branding/$file')
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('render branding', (t) async {
    addTearDown(t.view.reset);
    // Legacy / iOS icon: logo on the cream background, full bleed.
    await render(
      t,
      'icon.png',
      size: 1024,
      logoFraction: 0.78,
      background: AppColors.lightBackground,
    );
    // Adaptive icon foreground: must fit the 66% safe zone.
    await render(t, 'icon_foreground.png', size: 1024, logoFraction: 0.56);
    // Play Store listing icon (512 × 512, no transparency).
    await render(
      t,
      'play_store_icon_512.png',
      size: 512,
      logoFraction: 0.78,
      background: AppColors.lightBackground,
    );
    // Pre-Android-12 splash image (centred on the splash colour).
    await render(t, 'splash_logo.png', size: 768, logoFraction: 0.62);
    // Android 12+ splash icon: shown inside a circle of 2/3 the canvas.
    await render(t, 'splash_android12.png', size: 960, logoFraction: 0.58);
  });
}
