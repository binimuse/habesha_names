import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../routes/app_nav.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/ad_slots.dart';
import '../../../widgets/favorite_button.dart';
import '../../../widgets/name_carousel.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../controllers/name_detail_controller.dart';
import '../widgets/detail_header.dart';
import '../widgets/detail_sections.dart';
import '../widgets/report_sheet.dart';

class NameDetailView extends GetView<NameDetailController> {
  const NameDetailView({super.key, required this.args});

  final NameDetailArgs args;

  @override
  String? get tag => args.tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const BannerAdSlot(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Obx(
            () => controller.isReady.value
                ? Row(
                    children: [
                      IconButton(
                        tooltip: LocaleKeys.detailShare.tr,
                        onPressed: controller.share,
                        icon: const Icon(Icons.ios_share_rounded),
                      ),
                      FavoriteButton(nameId: args.id),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: controller.obx(
        (data) => _Body(data: data!, controllerTag: args.tag),
        onLoading: const LoadingView(),
        onError: (message) => message == NameNotFoundException.code
            ? EmptyView(
                icon: Icons.search_off_rounded,
                title: LocaleKeys.detailNotFound.tr,
              )
            : ErrorView(onRetry: controller.load),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data, required this.controllerTag});

  final NameDetailData data;
  final String controllerTag;

  @override
  Widget build(BuildContext context) {
    final NameDetailController c = Get.find<NameDetailController>(
      tag: controllerTag,
    );
    final List<Widget> sections = [
      MeaningSection(name: data.name),
      OriginSection(name: data.name),
      if (data.name.nicknames.isNotEmpty) NicknamesSection(name: data.name),
      if (data.name.famous.isNotEmpty) FamousSection(name: data.name),
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DetailHeader(controller: c, name: data.name),
        ...sections
            .animate(interval: 70.ms, delay: 150.ms)
            .fadeIn(duration: AppDurations.medium)
            .slideY(begin: 0.06, end: 0, curve: AppCurves.standard),
        if (data.similar.isNotEmpty) ...[
          SectionHeader(title: LocaleKeys.detailSimilar.tr),
          NameCarousel(
            section: c.similarSection,
            names: data.similar,
            onTap: c.openSimilar,
          ).animate().fadeIn(duration: AppDurations.slow),
        ],
        // Wrong meaning / spelling? Goes to the admin app's Reports tab.
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: Center(
            child: TextButton.icon(
              onPressed: () => ReportSheet.show(context, data.name),
              icon: const Icon(Icons.flag_outlined),
              label: Text(LocaleKeys.reportAction.tr),
            ),
          ),
        ),
        SizedBox(
          height: AppSpacing.xxxl + MediaQuery.paddingOf(context).bottom,
        ),
      ],
    );
  }
}
