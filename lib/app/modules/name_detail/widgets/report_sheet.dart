import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/name_model.dart';
import '../../../services/report_service.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';

/// "Report a mistake" form for one name. Stateful only for its text field
/// and chip selection; validation and the write live in [ReportService].
class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key, required this.name});

  final NameModel name;

  static Future<void> show(BuildContext context, NameModel name) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => ReportSheet(name: name),
      );

  static String labelKey(ReportField f) => switch (f) {
    ReportField.meaning => LocaleKeys.reportFieldMeaning,
    ReportField.geez => LocaleKeys.reportFieldGeez,
    ReportField.spelling => LocaleKeys.reportFieldSpelling,
    ReportField.pronunciation => LocaleKeys.reportFieldPronunciation,
    ReportField.gender => LocaleKeys.reportFieldGender,
    ReportField.origin => LocaleKeys.reportFieldOrigin,
    ReportField.other => LocaleKeys.reportFieldOther,
  };

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  final TextEditingController _message = TextEditingController();
  final Set<ReportField> _fields = {};
  bool _busy = false;
  bool _sent = false;
  String? _errorKey;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _errorKey = null;
    });
    try {
      await Get.find<ReportService>().submit(
        widget.name,
        fields: _fields,
        message: _message.text,
        language: Get.locale?.languageCode ?? 'en',
      );
      setState(() => _sent = true);
    } on ReportException catch (e) {
      setState(
        () => _errorKey = e.reason == 'input'
            ? LocaleKeys.reportNeedInput
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
                    Icons.task_alt_rounded,
                    size: 56,
                    color: context.palette.gold,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    LocaleKeys.reportThanks.tr,
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
                  Text(
                    LocaleKeys.reportTitle.trParams({
                      'name':
                          '${widget.name.nameLatin} · '
                          '${widget.name.nameGeez}',
                    }),
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(LocaleKeys.reportIntro.tr, style: text.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final ReportField f in ReportField.values)
                        FilterChip(
                          label: Text(ReportSheet.labelKey(f).tr),
                          selected: _fields.contains(f),
                          onSelected: (on) => setState(
                            () => on ? _fields.add(f) : _fields.remove(f),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _message,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: ReportService.maxMessage,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.reportMessage.tr,
                      hintText: LocaleKeys.reportMessageHint.tr,
                      alignLabelWithHint: true,
                    ),
                  ),
                  if (_errorKey != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        _errorKey!.tr,
                        style: TextStyle(color: context.colors.error),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: _busy ? null : _send,
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(LocaleKeys.reportSend.tr),
                  ),
                ],
              ),
      ),
    );
  }
}
