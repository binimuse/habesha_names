import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/reveal_encoding.dart';
import '../controllers/reveal_video_controller.dart';
import '../widgets/reveal_template.dart';

class RevealVideoView extends GetView<RevealVideoController> {
  const RevealVideoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.videoTitle.tr)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: context.palette.cardShadow,
                      ),
                      child: RepaintBoundary(
                        key: controller.frameKey,
                        child: Obx(
                          () => controller.exporting.value
                              ? RevealTemplate(
                                  name: controller.name,
                                  t: controller.frameT.value,
                                )
                              : _LoopingPreview(controller: controller),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: Obx(() {
                if (controller.exporting.value) {
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: controller.percent.value / 100,
                        color: context.palette.gold,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        LocaleKeys.videoRendering.trParams({
                          'percent': '${controller.percent.value}',
                        }),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (controller.failed.value) ...[
                      Text(
                        LocaleKeys.videoFailed.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.error),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    FilledButton.icon(
                      onPressed: controller.export,
                      icon: const Icon(Icons.movie_creation_rounded),
                      label: Text(LocaleKeys.videoExport.tr),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loops the animation in real time while not exporting.
class _LoopingPreview extends StatefulWidget {
  const _LoopingPreview({required this.controller});

  final RevealVideoController controller;

  @override
  State<_LoopingPreview> createState() => _LoopingPreviewState();
}

class _LoopingPreviewState extends State<_LoopingPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    // Hold the finished frame for a moment before looping.
    duration: RevealSpec.length + const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double total = (RevealSpec.length.inMilliseconds + 2000).toDouble();
    final double share = RevealSpec.length.inMilliseconds / total;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => RevealTemplate(
        name: widget.controller.name,
        t: (_anim.value / share).clamp(0.0, 1.0),
      ),
    );
  }
}
