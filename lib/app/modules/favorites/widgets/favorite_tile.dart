import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/utils/labels.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/gender_style.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/name_card.dart';
import '../../../widgets/name_title.dart';
import '../controllers/favorites_controller.dart';
import 'note_sheet.dart';

/// Favorite with its note. Swipe to remove; selectable in compare mode.
class FavoriteTile extends GetView<FavoritesController> {
  const FavoriteTile({super.key, required this.entry});

  final FavoriteEntry entry;

  @override
  Widget build(BuildContext context) {
    final String heroTag = nameHeroTag('favorites', entry.name.id);
    final BorderRadius radius = BorderRadius.circular(AppRadius.card);
    final TextTheme text = Theme.of(context).textTheme;
    final String note = entry.favorite.note;

    return Dismissible(
      key: ValueKey('fav-${entry.name.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.remove(entry.name.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.colors.error.withValues(alpha: 0.12),
          borderRadius: radius,
        ),
        child: Icon(Icons.delete_outline_rounded, color: context.colors.error),
      ),
      child: Obx(() {
        final bool selecting = controller.selecting.value;
        final bool selected = controller.selected.contains(entry.name.id);
        return AnimatedContainer(
          duration: AppDurations.medium,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected ? context.colors.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: context.palette.cardShadow,
          ),
          child: Material(
            color: context.colors.surface,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => controller.onTap(entry, heroTag),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 48,
                          decoration: BoxDecoration(
                            color: entry.name.gender.color(context.palette),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Hero(
                            tag: heroTag,
                            child: NameTitle(name: entry.name, height: 56),
                          ),
                        ),
                        if (selecting)
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: selected
                                  ? context.colors.primary
                                  : context.palette.inkMuted,
                            ),
                          )
                        else
                          IconButton(
                            tooltip: note.isEmpty
                                ? LocaleKeys.favoritesAddNote.tr
                                : LocaleKeys.favoritesEditNote.tr,
                            icon: Icon(
                              note.isEmpty
                                  ? Icons.edit_note_rounded
                                  : Icons.sticky_note_2_outlined,
                            ),
                            onPressed: () => _editNote(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.lg + 2),
                      child: Text(
                        Labels.meaning(entry.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium!.copyWith(
                          color: context.palette.inkMuted,
                        ),
                      ),
                    ),
                    if (note.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.fromLTRB(
                          AppSpacing.lg + 2,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.xs,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: context.palette.goldSoft,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          note,
                          style: text.bodyMedium!.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _editNote(BuildContext context) async {
    final String? note = await NoteSheet.show(
      context,
      initial: entry.favorite.note,
      title: entry.name.nameLatin,
    );
    if (note != null) await controller.saveNote(entry.name.id, note);
  }
}
