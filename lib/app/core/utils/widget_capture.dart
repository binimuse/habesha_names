import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// Renders the [RepaintBoundary] behind [key] to PNG bytes.
/// [targetWidth] sets the output width in pixels (height keeps the ratio).
abstract final class WidgetCapture {
  static Future<Uint8List> png(
    GlobalKey key, {
    required int targetWidth,
  }) async {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final double ratio = targetWidth / boundary.size.width;
    final ui.Image image = await boundary.toImage(pixelRatio: ratio);
    try {
      final ByteData? data = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  /// Writes [bytes] to a temp file (for sharing) and returns it.
  static Future<File> toTempFile(Uint8List bytes, String fileName) async {
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
