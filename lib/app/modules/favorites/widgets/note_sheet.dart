import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';

/// Bottom sheet with a text field. Returns the note, or null if dismissed.
/// Stateful only to own its [TextEditingController] (pure UI state).
class NoteSheet extends StatefulWidget {
  const NoteSheet({super.key, required this.initial, required this.title});

  final String initial;
  final String title;

  static Future<String?> show(
    BuildContext context, {
    required String initial,
    required String title,
  }) => showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => NoteSheet(initial: initial, title: title),
  );

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _text,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: LocaleKeys.favoritesNoteHint.tr,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_text.text),
            child: Text(LocaleKeys.favoritesSave.tr),
          ),
        ],
      ),
    );
  }
}
