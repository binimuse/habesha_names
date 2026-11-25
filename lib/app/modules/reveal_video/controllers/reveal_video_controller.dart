import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/app_share.dart';
import '../../../core/utils/widget_capture.dart';
import '../../../data/models/name_model.dart';
import '../../../translations/locale_keys.dart';
import 'reveal_encoding.dart';

/// Renders the reveal animation frame by frame, encodes an MP4 and opens the
/// share sheet (TikTok, Instagram, Telegram… whatever is installed).
class RevealVideoController extends GetxController {
  RevealVideoController(
    this.name, {
    VideoEncoder? encoder,
    Future<Directory> Function()? tempDir,
    Future<void> Function(String path)? share,
    int? frames,
  }) : frameCount = frames ?? RevealSpec.frames,
       _encoder = encoder ?? FfmpegVideoEncoder(),
       _tempDir = tempDir ?? getTemporaryDirectory,
       _share = share;

  final NameModel name;

  /// Frames to render (tests use a few; the app uses [RevealSpec.frames]).
  final int frameCount;
  final VideoEncoder _encoder;
  final Future<Directory> Function() _tempDir;
  final Future<void> Function(String path)? _share;

  final GlobalKey frameKey = GlobalKey();
  final RxBool exporting = false.obs;

  /// Progress of the frame being rendered (drives the template on export).
  final RxDouble frameT = 0.0.obs;
  final RxInt percent = 0.obs;
  final RxBool failed = false.obs;

  /// Path of the last exported video.
  String? lastVideo;

  Future<void> export() async {
    if (exporting.value) return;
    exporting.value = true;
    failed.value = false;
    percent.value = 0;
    final Directory root = await _tempDir();
    final Directory frames = Directory(
      '${root.path}/reveal_${DateTime.now().millisecondsSinceEpoch}',
    )..createSync(recursive: true);
    try {
      final int total = frameCount;
      for (int i = 0; i < total; i++) {
        frameT.value = i / (total - 1);
        await WidgetsBinding.instance.endOfFrame;
        final bytes = await WidgetCapture.png(
          frameKey,
          targetWidth: RevealSpec.width,
        );
        await File(
          '${frames.path}/${RevealSpec.frameName(i)}',
        ).writeAsBytes(bytes);
        percent.value = ((i + 1) * 90 / total).round(); // encoding = last 10%
      }
      final String out = '${root.path}/habesha-${name.id}-reveal.mp4';
      final bool ok = await _encoder.encode(
        framesDir: frames.path,
        output: out,
      );
      if (!ok) throw StateError('encode failed');
      percent.value = 100;
      lastVideo = out;
      await (_share ?? _shareSheet)(out);
    } catch (error) {
      debugPrint('Reveal export failed: $error');
      failed.value = true;
    } finally {
      if (frames.existsSync()) frames.deleteSync(recursive: true);
      exporting.value = false;
    }
  }

  Future<void> _shareSheet(String path) => AppShare.share(
    'reveal_video',
    name.id,
    ShareParams(
      files: [XFile(path, mimeType: 'video/mp4')],
      text: LocaleKeys.videoShareText.trParams({'name': name.nameLatin}),
    ),
  );
}
