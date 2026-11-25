import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/labels.dart';
import '../../../data/models/gender.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/reveal_encoding.dart';

/// 9:16 reveal frame at animation progress [t] (0–1). Pure function of [t],
/// so the live preview and the exported frames are identical.
class RevealTemplate extends StatelessWidget {
  const RevealTemplate({super.key, required this.name, required this.t});

  final NameModel name;
  final double t;

  @override
  Widget build(BuildContext context) {
    final Color tint = switch (name.gender) {
      Gender.girl => AppColors.girl,
      Gender.boy => AppColors.boy,
      Gender.unisex => AppColors.unisex,
    };
    const Color bg = AppColors.lightBackground;
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Theme(
        data: Theme.of(context).copyWith(scaffoldBackgroundColor: bg),
        child: LayoutBuilder(
          builder: (context, box) {
            final double u = box.maxWidth / 100;
            Widget fadeUp(double v, Widget child) => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 6 * u),
                child: child,
              ),
            );
            final double bands = RevealTimeline.bands(t);
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(bg, tint, 0.35)!,
                    bg,
                    Color.lerp(bg, AppColors.gold, 0.15)!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  for (int i = 0; i < 8; i++) _sparkle(i, u, box),
                  Column(
                    children: [
                      Transform.translate(
                        offset: Offset((bands - 1) * box.maxWidth, 0),
                        child: TiletBand(height: 7 * u),
                      ),
                      const Spacer(flex: 3),
                      fadeUp(
                        RevealTimeline.intro(t),
                        Text(
                          LocaleKeys.videoIntro.tr,
                          style: TextStyle(
                            color: AppColors.lightInkMuted,
                            fontSize: 5.5 * u,
                            letterSpacing: 0.3 * u,
                          ),
                        ),
                      ),
                      SizedBox(height: 4 * u),
                      Transform.scale(
                        scale: 0.85 + 0.15 * RevealTimeline.latin(t),
                        child: Opacity(
                          opacity: RevealTimeline.latin(t),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6 * u),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                name.nameLatin,
                                style: AppTypography.nameDisplay(
                                  AppColors.terracotta,
                                ).copyWith(fontSize: 20 * u),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2 * u),
                      fadeUp(
                        RevealTimeline.geez(t),
                        Text(
                          name.nameGeez,
                          style: AppTypography.nameGeez(
                            AppColors.lightInk,
                          ).copyWith(fontSize: 11 * u),
                        ),
                      ),
                      SizedBox(height: 6 * u),
                      fadeUp(
                        RevealTimeline.meaning(t),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10 * u),
                          child: Text(
                            Labels.meaning(name),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall!
                                .copyWith(
                                  color: AppColors.lightInk,
                                  fontSize: 6 * u,
                                ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 4),
                      Opacity(
                        opacity: RevealTimeline.watermark(t),
                        child: Text(
                          LocaleKeys.videoWatermark.tr,
                          style: TextStyle(
                            color: AppColors.lightInkMuted,
                            fontSize: 3.4 * u,
                            letterSpacing: 0.2 * u,
                          ),
                        ),
                      ),
                      SizedBox(height: 3 * u),
                      Transform.translate(
                        offset: Offset((1 - bands) * box.maxWidth, 0),
                        child: TiletBand(height: 7 * u),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sparkle(int i, double u, BoxConstraints box) {
    final double phase = (RevealTimeline.sparkle(t) + i / 8) % 1;
    final double x = (0.1 + 0.8 * ((i * 37) % 100) / 100) * box.maxWidth;
    final double y = (1 - phase) * box.maxHeight;
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: math.sin(phase * math.pi) * 0.6 * RevealTimeline.intro(t),
        child: Icon(
          i.isEven ? Icons.auto_awesome : Icons.favorite_rounded,
          size: (i.isEven ? 4 : 3) * u,
          color: i.isEven ? AppColors.gold : AppColors.girl,
        ),
      ),
    );
  }
}
