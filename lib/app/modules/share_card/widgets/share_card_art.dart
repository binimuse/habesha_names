import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/labels.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/share_card_controller.dart';

/// The shareable card (4:5). Uses fixed brand colours so it looks the same
/// whether the app is in light or dark mode.
class ShareCardArt extends StatelessWidget {
  const ShareCardArt({super.key, required this.name, required this.template});

  final NameModel name;
  final ShareCardTemplate template;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color ink, Color muted, Color accent) = switch (template) {
      ShareCardTemplate.classic => (
        AppColors.lightBackground,
        AppColors.lightInk,
        AppColors.lightInkMuted,
        AppColors.terracotta,
      ),
      ShareCardTemplate.tilet => (
        const Color(0xFFFFFFFF),
        AppColors.lightInk,
        AppColors.lightInkMuted,
        AppColors.gold,
      ),
      ShareCardTemplate.night => (
        AppColors.darkBackground,
        AppColors.darkInk,
        AppColors.darkInkMuted,
        AppColors.gold,
      ),
    };
    // TiletBand paints on the theme's scaffold colour; give it this card's.
    final ThemeData theme = Theme.of(
      context,
    ).copyWith(scaffoldBackgroundColor: bg);

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Theme(
        data: theme,
        child: ColoredBox(
          color: bg,
          child: LayoutBuilder(
            builder: (context, box) {
              final double u = box.maxWidth / 100; // 1% of the width
              final Widget body = Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * u),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        name.nameLatin,
                        style: AppTypography.nameDisplay(
                          template == ShareCardTemplate.night ? accent : ink,
                        ).copyWith(fontSize: 16 * u),
                      ),
                    ),
                    SizedBox(height: 1.5 * u),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        name.nameGeez,
                        style: AppTypography.nameGeez(
                          muted,
                        ).copyWith(fontSize: 9 * u),
                      ),
                    ),
                    SizedBox(height: 4 * u),
                    Container(width: 14 * u, height: 0.6 * u, color: accent),
                    SizedBox(height: 4 * u),
                    Text(
                      Labels.meaning(name),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(color: ink, fontSize: 5.2 * u),
                    ),
                  ],
                ),
              );
              return Column(
                children: [
                  TiletBand(
                    height: template == ShareCardTemplate.tilet ? 9 * u : 6 * u,
                  ),
                  if (template == ShareCardTemplate.tilet)
                    SizedBox(height: 2 * u),
                  Expanded(child: body),
                  Padding(
                    padding: EdgeInsets.only(bottom: 3 * u),
                    child: Text(
                      LocaleKeys.videoWatermark.tr,
                      style: TextStyle(
                        color: muted,
                        fontSize: 3 * u,
                        letterSpacing: 0.2 * u,
                      ),
                    ),
                  ),
                  if (template != ShareCardTemplate.classic)
                    TiletBand(
                      height: template == ShareCardTemplate.tilet
                          ? 9 * u
                          : 4 * u,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
