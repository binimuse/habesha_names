import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _band(fromLeft: true)),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _band(fromLeft: false)),
          ),
          Center(
            child: Obx(
              () => controller.hasError.value
                  ? ErrorView(onRetry: controller.start)
                  : const _Brand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _band({required bool fromLeft}) => const TiletBand(height: 30)
      .animate()
      .fadeIn(duration: AppDurations.slow)
      .slideX(
        begin: fromLeft ? -0.25 : 0.25,
        end: 0,
        duration: 900.ms,
        curve: AppCurves.standard,
      );
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(size: 108)
            .animate()
            .scale(
              begin: const Offset(0.6, 0.6),
              duration: 700.ms,
              curve: AppCurves.emphasized,
            )
            .fadeIn(duration: AppDurations.medium),
        const SizedBox(height: AppSpacing.xl),
        Text(LocaleKeys.appName.tr, style: text.displaySmall)
            .animate(delay: 250.ms)
            .fadeIn(duration: AppDurations.slow)
            .slideY(begin: 0.3, end: 0, curve: AppCurves.standard),
        const SizedBox(height: AppSpacing.sm),
        Text(
          LocaleKeys.splashTagline.tr,
          textAlign: TextAlign.center,
          style: text.bodyMedium!.copyWith(color: context.palette.inkMuted),
        ).animate(delay: 450.ms).fadeIn(duration: AppDurations.slow),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: context.palette.gold,
          ),
        ).animate(delay: 900.ms).fadeIn(),
      ],
    );
  }
}
