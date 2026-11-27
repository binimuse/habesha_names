import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme.dart';
import '../core/vocab.dart';
import '../data/admin_name.dart';
import '../data/admin_repository.dart';
import 'widgets/state_views.dart';

/// Route arguments: edit [id], or create a new name (optionally prefilled
/// from a user [suggestion], which is removed once the name is saved).
/// With a [report], the editor pins it on top and resolves it on publish.
class NameEditArgs {
  const NameEditArgs({this.id, this.suggestion, this.report});

  final String? id;
  final Suggestion? suggestion;
  final NameReport? report;
}

class NameEditController extends GetxController {
  NameEditController(this._repo, Object? args)
    : _args = args is NameEditArgs ? args : const NameEditArgs();

  final AdminRepository _repo;
  final NameEditArgs _args;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool get isNew => _args.id == null;

  final RxBool loading = false.obs;
  final RxBool saving = false.obs;
  final RxnString error = RxnString();

  /// Live and/or draft version as loaded; null for a brand-new name.
  final Rxn<NameEntry> entry = Rxn<NameEntry>();

  /// The user report this edit was opened from, if any.
  NameReport? get report => _args.report;

  /// Live status of [report] here: open → resolved / dismissed.
  late final RxString reportStatus = (_args.report?.status ?? '').obs;

  /// Close the report without (or after) editing.
  Future<void> setReportStatus(String status) async {
    final NameReport? r = report;
    if (r == null) return;
    try {
      await _repo.setReportStatus(r.id, status);
      reportStatus.value = status;
    } catch (e) {
      error.value = 'Could not update the report: $e';
    }
  }

  bool get isPublished => entry.value?.published != null;
  bool get hasDraft => entry.value?.draft != null;

  // Text fields.
  final TextEditingController id = TextEditingController();
  final TextEditingController latin = TextEditingController();
  final TextEditingController geez = TextEditingController();
  final TextEditingController meaningEn = TextEditingController();
  final TextEditingController meaningAm = TextEditingController();
  final TextEditingController pronunciation = TextEditingController();
  final TextEditingController audioUrl = TextEditingController();
  final TextEditingController syllables = TextEditingController();
  final TextEditingController originEn = TextEditingController();
  final TextEditingController originAm = TextEditingController();
  final TextEditingController popularity = TextEditingController();
  // Comma-separated lists.
  final TextEditingController spellings = TextEditingController();
  final TextEditingController nicknames = TextEditingController();
  final TextEditingController similar = TextEditingController();
  final TextEditingController famous = TextEditingController();

  // Choices.
  final RxString gender = 'girl'.obs;
  final RxSet<String> languages = <String>{'amharic'}.obs;
  final RxSet<String> faiths = <String>{'neutral'}.obs;
  final RxSet<String> themes = <String>{}.obs;
  final RxBool easyAbroad = false.obs;
  final RxBool verified = false.obs;
  final RxBool modern = false.obs;

  /// Read-only server fields, shown for context.
  String get serverInfo {
    final AdminName? o = entry.value?.published;
    if (o == null) return '';
    return 'rarity: ${o.rarity ?? '—'} · trend: ${o.trendScore} · '
        'updated: ${o.updatedAt?.toLocal().toString().substring(0, 16) ?? '—'}';
  }

  @override
  void onInit() {
    super.onInit();
    syllables.text = '0';
    popularity.text = '0';
    final Suggestion? s = _args.suggestion;
    if (s != null) {
      latin.text = s.nameLatin;
      geez.text = s.nameGeez;
      (s.language == 'am' ? meaningAm : meaningEn).text = s.meaning;
      id.text = slugify(s.nameLatin);
    }
    if (isNew) {
      latin.addListener(_autoId);
    } else {
      load();
    }
  }

  // New names: the id follows the Latin spelling until edited by hand.
  String _lastAutoId = '';
  void _autoId() {
    if (id.text == _lastAutoId) {
      id.text = _lastAutoId = slugify(latin.text);
    }
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final NameEntry? e = await _repo.getEntry(_args.id!);
      if (e == null) throw StateError('Name "${_args.id}" not found');
      entry.value = e;
      _fill(e.current); // the draft, if there is one
    } catch (e) {
      error.value = '$e';
    } finally {
      loading.value = false;
    }
  }

  void _fill(AdminName n) {
    id.text = n.id;
    latin.text = n.nameLatin;
    geez.text = n.nameGeez;
    meaningEn.text = n.meaningEn;
    meaningAm.text = n.meaningAm;
    pronunciation.text = n.pronunciation;
    audioUrl.text = n.audioUrl ?? '';
    syllables.text = '${n.syllables}';
    originEn.text = n.originEn;
    originAm.text = n.originAm;
    popularity.text = '${n.popularity}';
    spellings.text = n.spellings.join(', ');
    nicknames.text = n.nicknames.join(', ');
    similar.text = n.similar.join(', ');
    famous.text = n.famous.join(', ');
    gender.value = Vocab.genders.contains(n.gender) ? n.gender : 'unisex';
    languages.assignAll(n.languages);
    faiths.assignAll(n.faiths);
    themes.assignAll(n.themes);
    easyAbroad.value = n.easyAbroad;
    verified.value = n.verified;
    modern.value = n.modern;
  }

  void toggle(RxSet<String> set, String code) =>
      set.contains(code) ? set.remove(code) : set.add(code);

  static List<String> _list(TextEditingController c) => [
    for (final String s in c.text.split(','))
      if (s.trim().isNotEmpty) s.trim(),
  ];

  // -- Validators -------------------------------------------------------------

  String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? validateId(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (!RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(v)) {
      return 'Lowercase letters, digits and dashes only';
    }
    return null;
  }

  String? validateGeez(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (!RegExp(r'[ሀ-፿]').hasMatch(v)) return 'Use Ge\'ez letters';
    return null;
  }

  String? validateInt(String? v, {required int max}) {
    final int? n = int.tryParse(v?.trim() ?? '');
    if (n == null || n < 0 || n > max) return '0–$max';
    return null;
  }

  String? validateUrl(String? v) {
    final String s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    final Uri? u = Uri.tryParse(s);
    return (u != null && u.isScheme('https'))
        ? null
        : 'Must be an https:// URL';
  }

  // -- Save -------------------------------------------------------------------

  /// Saves to `name_drafts` only — phones keep the live version.
  Future<void> saveDraft() => _save(
    publish: false,
    message: (n) => isPublished
        ? 'Draft saved. The live version of $n is unchanged until you publish.'
        : 'Draft saved. $n is not visible in the app yet.',
  );

  /// Writes to `names` (phones get it on next sync) and drops the draft.
  Future<void> publish() => _save(
    publish: true,
    message: (n) => '$n is published — phones get it on their next sync.',
  );

  /// Throws away unpublished edits (or a never-published draft).
  Future<void> discardDraft() async {
    final NameEntry? e = entry.value;
    if (e?.draft == null) return;
    saving.value = true;
    try {
      await _repo.discardDraft(e!.id);
      Get.back<void>();
      Get.snackbar(
        'Draft discarded',
        e.published != null
            ? 'The live version of ${e.published!.nameLatin} stays as it was.'
            : '${e.draft!.nameLatin} was never published and is now removed.',
      );
    } catch (err) {
      error.value = 'Discard failed: $err';
    } finally {
      saving.value = false;
    }
  }

  Future<void> _save({
    required bool publish,
    required String Function(String name) message,
  }) async {
    error.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (languages.isEmpty) {
      error.value = 'Pick at least one language.';
      return;
    }
    if (faiths.isEmpty) {
      error.value = 'Pick at least one faith (use "neutral" if none).';
      return;
    }
    saving.value = true;
    try {
      final String docId = id.text.trim();
      if (isNew && await _repo.nameExists(docId)) {
        error.value = 'A name or draft with id "$docId" already exists.';
        return;
      }
      final AdminName name = AdminName(
        id: docId,
        nameLatin: latin.text.trim(),
        nameGeez: geez.text.trim(),
        gender: gender.value,
        spellings: {latin.text.trim(), ..._list(spellings)}.toList(),
        languages: Vocab.languages.where(languages.contains).toList(),
        faiths: Vocab.faiths.where(faiths.contains).toList(),
        themes: Vocab.themes.where(themes.contains).toList(),
        meaningEn: meaningEn.text.trim(),
        meaningAm: meaningAm.text.trim(),
        pronunciation: pronunciation.text.trim(),
        audioUrl: audioUrl.text.trim(),
        syllables: int.parse(syllables.text.trim()),
        easyAbroad: easyAbroad.value,
        originEn: originEn.text.trim(),
        originAm: originAm.text.trim(),
        nicknames: _list(nicknames),
        similar: _list(similar),
        famous: _list(famous),
        verified: verified.value,
        popularity: int.parse(popularity.text.trim()),
        modern: modern.value,
      );
      await (publish ? _repo.publish(name) : _repo.saveDraft(name));
      final Suggestion? s = _args.suggestion;
      if (s != null) await _repo.deleteSuggestion(s.id);
      // Publishing the fix closes the report it came from.
      final NameReport? r = _args.report;
      if (publish && r != null && r.isOpen) {
        await _repo.setReportStatus(r.id, 'resolved');
      }
      Get.back<void>();
      Get.snackbar(
        publish ? 'Published' : 'Draft saved',
        message(name.nameLatin),
      );
    } catch (e) {
      error.value = 'Save failed: $e';
    } finally {
      saving.value = false;
    }
  }

  @override
  void onClose() {
    for (final TextEditingController c in [
      id, latin, geez, meaningEn, meaningAm, pronunciation, audioUrl, //
      syllables, originEn, originAm, popularity, spellings, nicknames,
      similar, famous,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}

class NameEditPage extends GetView<NameEditController> {
  const NameEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isNew ? 'Add name' : 'Edit name'),
        actions: const [_Actions(), SizedBox(width: 16)],
      ),
      body: Obx(() {
        if (controller.loading.value) return const LoadingView();
        if (!controller.isNew &&
            controller.error.value != null &&
            controller.entry.value == null) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.load,
          );
        }
        return const _Form();
      }),
    );
  }
}

/// Discard draft · Save draft · Publish (icons only on phone-width windows).
class _Actions extends GetView<NameEditController> {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    final bool narrow = MediaQuery.sizeOf(context).width < 640;
    return Obx(() {
      final bool busy = controller.saving.value || controller.loading.value;
      final bool hasDraft = controller.hasDraft;
      final String publishLabel = controller.isPublished
          ? 'Publish changes'
          : 'Publish';
      if (narrow) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDraft)
              IconButton(
                tooltip: 'Discard draft',
                onPressed: busy ? null : controller.discardDraft,
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            IconButton(
              tooltip: 'Save draft',
              onPressed: busy ? null : controller.saveDraft,
              icon: const Icon(Icons.edit_note),
            ),
            IconButton.filled(
              tooltip: publishLabel,
              onPressed: busy ? null : controller.publish,
              icon: const Icon(Icons.publish),
            ),
          ],
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDraft) ...[
            TextButton(
              onPressed: busy ? null : controller.discardDraft,
              child: const Text('Discard draft'),
            ),
            const SizedBox(width: 8),
          ],
          OutlinedButton.icon(
            onPressed: busy ? null : controller.saveDraft,
            icon: const Icon(Icons.edit_note),
            label: const Text('Save draft'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: busy ? null : controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(controller.saving.value ? 'Saving…' : publishLabel),
          ),
        ],
      );
    });
  }
}

/// The user's report, pinned above the form while fixing the name.
class _ReportBanner extends GetView<NameEditController> {
  const _ReportBanner();

  @override
  Widget build(BuildContext context) {
    final NameReport? r = controller.report;
    if (r == null) return const SizedBox.shrink();
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      color: AdminColors.terracotta.withValues(alpha: 0.10),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AdminColors.terracotta),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, color: AdminColors.terracotta),
                const SizedBox(width: 8),
                Expanded(child: Text('User report', style: t.titleMedium)),
                Obx(
                  () => Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(controller.reportStatus.value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final String f in r.fields)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(NameReport.fieldLabels[f] ?? f),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(r.message, style: t.bodyLarge),
            const SizedBox(height: 4),
            Text(
              'Reported on "${r.nameLatin} · ${r.nameGeez}" · app in '
              '${r.language} · '
              '${r.createdAt?.toLocal().toString().substring(0, 16) ?? ''}',
              style: t.bodySmall,
            ),
            const SizedBox(height: 8),
            Obx(
              () => controller.reportStatus.value == 'open'
                  ? Wrap(
                      spacing: 8,
                      children: [
                        Text(
                          'Publishing your fix marks this resolved.',
                          style: t.bodySmall,
                        ),
                        TextButton(
                          onPressed: () =>
                              controller.setReportStatus('resolved'),
                          child: const Text('Mark resolved'),
                        ),
                        TextButton(
                          onPressed: () =>
                              controller.setReportStatus('dismissed'),
                          child: const Text('Dismiss (not a mistake)'),
                        ),
                      ],
                    )
                  : TextButton(
                      onPressed: () => controller.setReportStatus('open'),
                      child: const Text('Reopen'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where this name stands: draft only, live, or live with pending edits.
class _StatusBanner extends GetView<NameEditController> {
  const _StatusBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final NameEntry? e = controller.entry.value;
      final (IconData icon, String text) = switch (e?.status) {
        null => (
          Icons.fiber_new_outlined,
          'New name. "Save draft" keeps it hidden from the app; '
              '"Publish" makes it live.',
        ),
        NameStatus.draft => (
          Icons.edit_note,
          'Draft — not visible in the app yet.',
        ),
        NameStatus.changed => (
          Icons.pending_outlined,
          'Published, with unpublished changes. You are editing the draft; '
              'the app shows the live version until you publish.',
        ),
        NameStatus.published => (
          Icons.public,
          'Published. "Save draft" stages changes without touching the live '
              'version.',
        ),
        NameStatus.deleted => (
          Icons.delete_outline,
          'Deleted from the app. Publishing restores it.',
        ),
      };
      return Card(
        color: StatusColors.of(e?.status).withValues(alpha: 0.18),
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(leading: Icon(icon), title: Text(text)),
      );
    });
  }
}

class _Form extends GetView<NameEditController> {
  const _Form();

  @override
  Widget build(BuildContext context) {
    final NameEditController c = controller;
    return Form(
      key: c.formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(
                    () => c.error.value == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              c.error.value!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                  ),
                  const _ReportBanner(),
                  const _StatusBanner(),
                  _Section('Name', [
                    _Row([
                      _Field(
                        c.latin,
                        'Latin spelling *',
                        validator: c.required,
                      ),
                      _Field(c.geez, 'Ge\'ez *', validator: c.validateGeez),
                    ]),
                    _Row([
                      _Field(
                        c.id,
                        'Id (doc id)',
                        validator: c.validateId,
                        enabled: c.isNew,
                        helper: c.isNew
                            ? 'From the Latin spelling; can\'t change later'
                            : 'Fixed',
                      ),
                      _Field(
                        c.spellings,
                        'Other spellings',
                        helper: 'Comma-separated, e.g. Hiwot, Hiwet',
                      ),
                    ]),
                    const _GenderPicker(),
                  ]),
                  _Section('Meaning & origin', [
                    _Row([
                      _Field(c.meaningEn, 'Meaning (English)', lines: 2),
                      _Field(c.meaningAm, 'Meaning (Amharic)', lines: 2),
                    ]),
                    _Row([
                      _Field(c.originEn, 'Origin (English)'),
                      _Field(c.originAm, 'Origin (Amharic)'),
                    ]),
                  ]),
                  _Section('Tags', [
                    _Chips('Languages *', Vocab.languages, c.languages),
                    _Chips('Faiths *', Vocab.faiths, c.faiths),
                    _Chips('Themes', Vocab.themes, c.themes),
                    Wrap(
                      spacing: 24,
                      children: [
                        _Switch('Easy abroad', c.easyAbroad),
                        _Switch('Modern', c.modern),
                        _Switch('Verified', c.verified),
                      ],
                    ),
                  ]),
                  _Section('Sound', [
                    _Row([
                      _Field(c.pronunciation, 'Pronunciation (hee-WOT)'),
                      _Field(
                        c.syllables,
                        'Syllables',
                        validator: (v) => c.validateInt(v, max: 12),
                      ),
                    ]),
                    _Field(
                      c.audioUrl,
                      'Audio URL (https, optional)',
                      validator: c.validateUrl,
                    ),
                  ]),
                  _Section('More', [
                    _Row([
                      _Field(
                        c.nicknames,
                        'Nicknames',
                        helper: 'Comma-separated',
                      ),
                      _Field(
                        c.similar,
                        'Similar name ids',
                        helper: 'Comma-separated ids, e.g. selam, tsion',
                      ),
                    ]),
                    _Row([
                      _Field(
                        c.famous,
                        'Famous people',
                        helper: 'Comma-separated',
                      ),
                      _Field(
                        c.popularity,
                        'Popularity (0–100)',
                        validator: (v) => c.validateInt(v, max: 100),
                      ),
                    ]),
                    if (!c.isNew)
                      Text(
                        c.serverInfo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          for (final Widget w in children) ...[w, const SizedBox(height: 12)],
        ],
      ),
    ),
  );
}

/// Two fields side by side on wide screens, stacked on narrow ones.
class _Row extends StatelessWidget {
  const _Row(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, box) => box.maxWidth < 560
        ? Column(
            children: [
              for (final Widget w in children) ...[
                w,
                const SizedBox(height: 12),
              ],
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: children[i]),
              ],
            ],
          ),
  );
}

class _Field extends StatelessWidget {
  const _Field(
    this.controller,
    this.label, {
    this.validator,
    this.helper,
    this.lines = 1,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final String? helper;
  final int lines;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    enabled: enabled,
    minLines: lines,
    maxLines: lines == 1 ? 1 : 4,
    decoration: InputDecoration(labelText: label, helperText: helper),
  );
}

class _GenderPicker extends GetView<NameEditController> {
  const _GenderPicker();

  @override
  Widget build(BuildContext context) => Obx(
    () => SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'girl', label: Text('Girl')),
        ButtonSegment(value: 'boy', label: Text('Boy')),
        ButtonSegment(value: 'unisex', label: Text('Unisex')),
      ],
      selected: {controller.gender.value},
      onSelectionChanged: (s) => controller.gender.value = s.first,
    ),
  );
}

class _Chips extends GetView<NameEditController> {
  const _Chips(this.label, this.options, this.selected);

  final String label;
  final List<String> options;
  final RxSet<String> selected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final String o in options)
              FilterChip(
                label: Text(o),
                selected: selected.contains(o),
                onSelected: (_) => controller.toggle(selected, o),
              ),
          ],
        ),
      ),
    ],
  );
}

class _Switch extends StatelessWidget {
  const _Switch(this.label, this.value);

  final String label;
  final RxBool value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Obx(() => Switch(value: value.value, onChanged: value.call)),
      const SizedBox(width: 4),
      Text(label),
    ],
  );
}
