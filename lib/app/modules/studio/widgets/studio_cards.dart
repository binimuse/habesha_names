import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/ai_feature.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/app_card.dart';
import '../controllers/studio_controller.dart';
import 'coming_soon_sheet.dart';

/// Gradient band with icon, title and the "Coming soon" pill.
class StudioCardHeader extends StatelessWidget {
  const StudioCardHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const Spacer(),
              const ComingSoonPill(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: text.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: text.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class ComingSoonPill extends StatelessWidget {
  const ComingSoonPill({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
    ),
    child: Text(
      LocaleKeys.studioComingSoon.tr,
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: Colors.white),
    ),
  );
}

/// AI Name Finder: gender, style chips and a free-text wish (preview UI).
class NameFinderCard extends GetView<StudioController> {
  const NameFinderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudioCardHeader(
            icon: Icons.auto_awesome_rounded,
            title: LocaleKeys.studioFinderTitle.tr,
            body: LocaleKeys.studioFinderBody.tr,
            colors: [context.colors.primary, context.palette.gold],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final (String? value, String key) in const [
                        ('girl', LocaleKeys.genderGirl),
                        ('boy', LocaleKeys.genderBoy),
                        (null, LocaleKeys.studioGenderAny),
                      ])
                        ChoiceChip(
                          label: Text(key.tr),
                          selected: controller.gender.value == value,
                          onSelected: (_) => controller.gender.value = value,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(LocaleKeys.studioStyle.tr, style: text.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Obx(
                  () => Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final StudioStyle s in StudioStyle.values)
                        FilterChip(
                          label: Text(s.labelKey.tr),
                          selected: controller.styles.contains(s),
                          onSelected: (_) => controller.toggleStyle(s),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: controller.prompt,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.studioPromptLabel.tr,
                    hintText: LocaleKeys.studioPromptHint.tr,
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        ComingSoonSheet.show(context, AiFeature.nameFinder),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(LocaleKeys.studioFind.tr),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baby Face Preview: two parent photo slots + baby gender (preview UI).
class FacePreviewCard extends GetView<StudioController> {
  const FacePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    void soon() => ComingSoonSheet.show(context, AiFeature.facePreview);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudioCardHeader(
            icon: Icons.face_retouching_natural_rounded,
            title: LocaleKeys.studioFaceTitle.tr,
            body: LocaleKeys.studioFaceBody.tr,
            colors: [context.palette.boy, context.palette.girl],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _PhotoSlot(
                        label: LocaleKeys.studioParentA.tr,
                        onTap: soon,
                      ),
                    ),
                    const _BabyPlaceholder(),
                    Expanded(
                      child: _PhotoSlot(
                        label: LocaleKeys.studioParentB.tr,
                        onTap: soon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Text(LocaleKeys.studioBabyIs.tr, style: text.labelLarge),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Obx(
                        () => SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: 'girl',
                              label: Text(LocaleKeys.genderGirl.tr),
                            ),
                            ButtonSegment(
                              value: 'boy',
                              label: Text(LocaleKeys.genderBoy.tr),
                            ),
                          ],
                          selected: {controller.babyGender.value},
                          onSelectionChanged: (s) =>
                              controller.babyGender.value = s.first,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: soon,
                    icon: const Icon(Icons.child_care_rounded),
                    label: Text(LocaleKeys.studioPreview.tr),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.palette.surfaceMuted,
                border: Border.all(color: context.colors.outlineVariant),
              ),
              child: Icon(
                Icons.add_a_photo_outlined,
                color: context.palette.inkMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: text.labelLarge, textAlign: TextAlign.center),
            Text(
              LocaleKeys.studioAddPhoto.tr,
              style: text.bodySmall?.copyWith(color: context.palette.inkMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BabyPlaceholder extends StatelessWidget {
  const _BabyPlaceholder();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    child: Column(
      children: [
        Icon(Icons.add_rounded, color: context.palette.inkMuted, size: 18),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [context.palette.girlSoft, context.palette.boySoft],
            ),
          ),
          child: Icon(
            Icons.child_care_rounded,
            color: context.colors.primary,
            size: 30,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    ),
  );
}
