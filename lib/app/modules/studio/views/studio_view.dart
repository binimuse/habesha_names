import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/page_header.dart';
import '../controllers/studio_controller.dart';
import '../widgets/studio_cards.dart';

/// 5th tab: AI tools shown as previews. Using either one says "Coming soon"
/// and offers the AI waitlist. No loading/error states: nothing is fetched.
class StudioView extends GetView<StudioController> {
  const StudioView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: LocaleKeys.studioTitle.tr,
            subtitle: LocaleKeys.studioSubtitle.tr,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.xxxl,
              ),
              children:
                  const [
                        NameFinderCard(),
                        SizedBox(height: AppSpacing.lg),
                        FacePreviewCard(),
                      ]
                      .animate(interval: 80.ms)
                      .fadeIn(duration: AppDurations.medium)
                      .slideY(begin: 0.05, end: 0, curve: AppCurves.standard),
            ),
          ),
        ],
      ),
    );
  }
}
