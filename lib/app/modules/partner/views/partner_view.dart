import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/couple.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/partner_controller.dart';

class PartnerView extends GetView<PartnerController> {
  const PartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.partnerTitle.tr)),
      body: !controller.isAvailable
          ? EmptyView(
              icon: Icons.cloud_off_rounded,
              accent: context.palette.boy,
              title: LocaleKeys.partnerUnavailableTitle.tr,
              message: LocaleKeys.partnerUnavailableMessage.tr,
            )
          : Obx(
              () => ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.xxxl,
                ),
                children: [
                  const _Hero(),
                  const SizedBox(height: AppSpacing.xl),
                  if (!controller.hasCode) ...[
                    const _CreateCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _JoinCard(),
                  ] else if (!controller.isLinked)
                    const _WaitingCard()
                  else
                    const _LinkedCard(),
                  if (controller.errorKey.value != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      controller.errorKey.value!.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.error),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox(
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(-22, 0),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 76,
                  color: context.palette.girl,
                ),
              ),
              Transform.translate(
                offset: const Offset(22, 0),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 76,
                  color: context.palette.boy.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ).animate().scale(
          begin: const Offset(0.7, 0.7),
          curve: AppCurves.emphasized,
          duration: AppDurations.slow,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          LocaleKeys.partnerSubtitle.tr,
          textAlign: TextAlign.center,
          style: text.titleMedium,
        ),
      ],
    );
  }
}

class _CreateCard extends GetView<PartnerController> {
  const _CreateCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.partnerCreateHint.tr,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: controller.busy ? null : controller.create,
            icon: const Icon(Icons.add_link_rounded),
            label: Text(LocaleKeys.partnerCreate.tr),
          ),
        ],
      ),
    );
  }
}

class _JoinCard extends GetView<PartnerController> {
  const _JoinCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.partnerJoinHint.tr,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: controller.codeInput,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: CoupleCode.length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(letterSpacing: 10),
            decoration: InputDecoration(
              hintText: '••••••',
              labelText: LocaleKeys.partnerCodeLabel.tr,
              counterText: '',
            ),
            onSubmitted: (_) => controller.join(),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: controller.busy ? null : controller.join,
            child: Text(LocaleKeys.partnerJoin.tr),
          ),
        ],
      ),
    );
  }
}

class _CodeDisplay extends GetView<PartnerController> {
  const _CodeDisplay();

  @override
  Widget build(BuildContext context) {
    final String code = controller.code;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < code.length; i++) ...[
          if (i == 3) const SizedBox(width: AppSpacing.md),
          Container(
            width: 40,
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.palette.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              code[i],
              style: context.appText.nameDisplay.copyWith(fontSize: 28),
            ),
          ),
        ],
      ],
    );
  }
}

class _WaitingCard extends GetView<PartnerController> {
  const _WaitingCard();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const TiletBand(height: 14),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Text(LocaleKeys.partnerYourCode.tr, style: text.labelLarge),
                const SizedBox(height: AppSpacing.md),
                const _CodeDisplay(),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      tooltip: LocaleKeys.partnerCopied.tr,
                      onPressed: controller.copyCode,
                      icon: const Icon(Icons.copy_rounded),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: controller.shareCode,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: Text(LocaleKeys.partnerShareCode.tr),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.palette.gold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      LocaleKeys.partnerWaiting.tr,
                      style: text.bodyMedium!.copyWith(
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: controller.busy ? null : controller.leave,
                  child: Text(LocaleKeys.favoritesCancel.tr),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedCard extends GetView<PartnerController> {
  const _LinkedCard();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: context.palette.unisex,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            LocaleKeys.partnerLinked.tr,
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            LocaleKeys.partnerLinkedHint.tr,
            textAlign: TextAlign.center,
            style: text.bodyMedium!.copyWith(color: context.palette.inkMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: controller.openMatches,
            icon: const Icon(Icons.favorite_rounded),
            label: Text(
              '${LocaleKeys.matchesTitle.tr} · ${controller.matchCount}',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: controller.busy ? null : controller.leave,
            child: Text(LocaleKeys.partnerLeave.tr),
          ),
        ],
      ),
    );
  }
}
