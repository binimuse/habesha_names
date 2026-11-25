import 'dart:io';
import 'dart:math' as math;

import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';
import 'package:flutter/foundation.dart';

/// Video settings for the reveal clip.
abstract final class RevealSpec {
  static const int fps = 30;
  static const Duration length = Duration(seconds: 6);
  static const int width = 720; // 9:16 → 720 × 1280
  static const int height = 1280;

  static int get frames => fps * length.inSeconds;

  static String frameName(int i) => 'f_${i.toString().padLeft(4, '0')}.png';
}

/// Timing of the animation, t ∈ [0, 1] over [RevealSpec.length].
abstract final class RevealTimeline {
  static double _seg(double t, double start, double end) =>
      ((t - start) / (end - start)).clamp(0.0, 1.0);

  static double _ease(double x) => 1 - math.pow(1 - x, 3).toDouble();

  static double bands(double t) => _ease(_seg(t, 0.00, 0.12));
  static double intro(double t) => _ease(_seg(t, 0.08, 0.25));
  static double latin(double t) => _ease(_seg(t, 0.25, 0.48));
  static double geez(double t) => _ease(_seg(t, 0.45, 0.62));
  static double meaning(double t) => _ease(_seg(t, 0.60, 0.78));
  static double watermark(double t) => _ease(_seg(t, 0.05, 0.20));

  /// Gentle sparkle drift for decoration (0–1 loop).
  static double sparkle(double t) => (t * 2) % 1;
}

/// FFmpeg argument lists to try in order: the device's hardware H.264
/// encoder first, then a software MPEG-4 fallback that always exists.
abstract final class RevealEncoding {
  static List<List<String>> attempts({
    required String framesDir,
    required String output,
    required bool ios,
    int fps = RevealSpec.fps,
  }) {
    List<String> withCodec(List<String> codec) => [
      '-y',
      '-framerate',
      '$fps',
      '-i',
      '$framesDir/f_%04d.png',
      ...codec,
      '-pix_fmt',
      'yuv420p',
      '-movflags',
      '+faststart',
      output,
    ];
    return [
      withCodec([
        '-c:v',
        ios ? 'h264_videotoolbox' : 'h264_mediacodec',
        '-b:v',
        '6M',
      ]),
      withCodec(['-c:v', 'mpeg4', '-q:v', '3']),
    ];
  }
}

abstract interface class VideoEncoder {
  /// Encodes `f_0000.png…` in [framesDir] to [output]. True on success.
  Future<bool> encode({required String framesDir, required String output});
}

class FfmpegVideoEncoder implements VideoEncoder {
  @override
  Future<bool> encode({
    required String framesDir,
    required String output,
  }) async {
    for (final List<String> args in RevealEncoding.attempts(
      framesDir: framesDir,
      output: output,
      ios: Platform.isIOS,
    )) {
      final FFmpegSession session = await FFmpegKit.executeWithArguments(args);
      if (ReturnCode.isSuccess(await session.getReturnCode())) return true;
      debugPrint(
        'ffmpeg failed (${args[args.indexOf('-c:v') + 1]}), '
        'trying next encoder',
      );
    }
    return false;
  }
}
