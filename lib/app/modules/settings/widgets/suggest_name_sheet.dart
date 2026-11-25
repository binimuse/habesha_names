import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../services/suggestion_service.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';

/// "Suggest a name" form. Stateful only for its text controllers.
class SuggestNameSheet extends StatefulWidget {
  const SuggestNameSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const SuggestNameSheet(),
  );

  @override
  State<SuggestNameSheet> createState() => _SuggestNameSheetState();
}

class _SuggestNameSheetState extends State<SuggestNameSheet> {
  final TextEditingController _latin = TextEditingController();
  final TextEditingController _geez = TextEditingController();
  final TextEditingController _meaning = TextEditingController();
  final TextEditingController _note = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _errorKey;

  @override
  void dispose() {
    for (final c in [_latin, _geez, _meaning, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _errorKey = null;
    });
    try {
      await Get.find<SuggestionService>().submit(
        NameSuggestion(
          nameLatin: _latin.text,
          nameGeez: _geez.text,
          meaning: _meaning.text,
          note: _note.text,
        ),
        language: Get.locale?.languageCode ?? 'en',
      );
      setState(() => _sent = true);
    } on SuggestionException catch (e) {
      setState(
        () => _errorKey = e.reason == 'name'
            ? LocaleKeys.suggestNameRequired
            : LocaleKeys.aiErrorOffline,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: _sent
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.volunteer_activism_rounded,
                    size: 56,
                    color: context.palette.gold,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    LocaleKeys.suggestThanks.tr,
                    textAlign: TextAlign.center,
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(LocaleKeys.aiClose.tr),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(LocaleKeys.suggestTitle.tr, style: text.headlineSmall),
                  const SizedBox(height: AppSpacing.lg),
                  _field(
                    _latin,
                    LocaleKeys.suggestLatin.tr,
                    max: NameSuggestion.maxShort,
                    autofocus: true,
                  ),
                  _field(
                    _geez,
                    LocaleKeys.suggestGeez.tr,
                    max: NameSuggestion.maxShort,
                  ),
                  _field(
                    _meaning,
                    LocaleKeys.suggestMeaning.tr,
                    max: NameSuggestion.maxLong,
                    lines: 2,
                  ),
                  _field(
                    _note,
                    LocaleKeys.suggestNote.tr,
                    max: NameSuggestion.maxLong,
                    lines: 3,
                  ),
                  if (_errorKey != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        _errorKey!.tr,
                        style: TextStyle(color: context.colors.error),
                      ),
                    ),
                  FilledButton(
                    onPressed: _busy ? null : _send,
                    child: Text(LocaleKeys.suggestSend.tr),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    required int max,
    int lines = 1,
    bool autofocus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: c,
        autofocus: autofocus,
        maxLength: max,
        minLines: lines,
        maxLines: lines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label, counterText: ''),
      ),
    );
  }
}
