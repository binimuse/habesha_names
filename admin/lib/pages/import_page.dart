import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/csv_import.dart';
import '../data/admin_name.dart';
import '../data/admin_repository.dart';
import 'names_page.dart';

/// Bulk import: paste from Excel / Google Sheets (tabs) or CSV text,
/// preview every row, then write the new + changed names in batches.
class ImportController extends GetxController {
  ImportController(this._repo, this._names);

  final AdminRepository _repo;
  final NamesController _names;

  final TextEditingController input = TextEditingController();
  final RxBool allowUpdates = true.obs;

  /// Default: land as drafts to review, then "Publish all" on the Names tab.
  final RxBool asDrafts = true.obs;
  final Rxn<ImportPreview> preview = Rxn<ImportPreview>();
  final RxBool importing = false.obs;
  final RxInt done = 0.obs;
  final RxnString result = RxnString();

  bool get canImport =>
      !importing.value &&
      (preview.value?.errors.isEmpty ?? false) &&
      (preview.value?.toWrite.isNotEmpty ?? false);

  void check() {
    result.value = null;
    preview.value = previewImport(
      input.text,
      existing: {for (final NameEntry e in _names.all) e.id: e.current},
      allowUpdates: allowUpdates.value,
    );
  }

  /// Every id already used (live, draft or deleted) — paste into the AI
  /// prompt so a new batch skips them.
  Future<void> copyIds() async {
    final List<String> ids = [for (final NameEntry e in _names.all) e.id]
      ..sort();
    await Clipboard.setData(ClipboardData(text: ids.join(', ')));
    Get.snackbar('Copied', '${ids.length} existing ids copied.');
  }

  Future<void> copyTemplate() async {
    await Clipboard.setData(
      const ClipboardData(text: '$importTemplateHeader\n'),
    );
    Get.snackbar(
      'Template copied',
      'Paste it into cell A1 of a new sheet, fill rows, then copy them back.',
    );
  }

  Future<void> runImport() async {
    final ImportPreview? p = preview.value;
    if (p == null || !canImport) return;
    final List<AdminName> names = p.toWrite;
    importing.value = true;
    done.value = 0;
    try {
      await _repo.importNames(
        names,
        asDrafts: asDrafts.value,
        onProgress: done.call,
      );
      result.value =
          'Imported ${names.length} names '
          '(${p.count(ImportAction.add)} new, '
          '${p.count(ImportAction.update)} updated). '
          '${asDrafts.value ? 'Saved as drafts — review them on the Names tab, then Publish all.' : 'Live — phones get them on their next sync.'}';
      preview.value = null;
      input.clear();
    } catch (e) {
      result.value =
          'Import stopped after ${done.value} of ${names.length}: $e';
    } finally {
      importing.value = false;
    }
  }

  @override
  void onClose() {
    input.dispose();
    super.onClose();
  }
}

class ImportPage extends GetView<ImportController> {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ImportController c = controller;
    final TextTheme t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk import names')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'In Excel or Google Sheets, select the header row plus '
                    'your names and copy (Ctrl+C), then paste below. CSV text '
                    'works too. Columns are the same as data/names.csv; '
                    'lists use | (e.g. amharic|tigrinya). Required: '
                    'name_latin, name_geez, gender.',
                    style: t.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: c.copyTemplate,
                        icon: const Icon(Icons.table_chart_outlined),
                        label: const Text('Copy blank template'),
                      ),
                      OutlinedButton.icon(
                        onPressed: c.copyIds,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Copy existing ids'),
                      ),
                      Obx(
                        () => FilterChip(
                          label: const Text('Import as drafts'),
                          tooltip: 'Off = publish straight to the app',
                          selected: c.asDrafts.value,
                          onSelected: c.asDrafts.call,
                        ),
                      ),
                      Obx(
                        () => FilterChip(
                          label: const Text('Update existing names'),
                          tooltip: 'Off = skip rows whose id already exists',
                          selected: c.allowUpdates.value,
                          onSelected: (v) {
                            c.allowUpdates.value = v;
                            if (c.preview.value != null) c.check();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: c.input,
                    minLines: 10,
                    maxLines: 18,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Paste here…',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (_) => c.preview.value = null,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: c.check,
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Check'),
                      ),
                      Obx(
                        () => FilledButton.icon(
                          onPressed: c.canImport ? c.runImport : null,
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: Text(
                            c.importing.value
                                ? 'Importing… ${c.done.value}'
                                : 'Import ${c.preview.value?.toWrite.length ?? 0} names',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => c.result.value == null
                        ? const SizedBox.shrink()
                        : Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(c.result.value!),
                            ),
                          ),
                  ),
                  Obx(() {
                    final ImportPreview? p = c.preview.value;
                    return p == null
                        ? const SizedBox.shrink()
                        : _PreviewView(preview: p);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({required this.preview});

  final ImportPreview preview;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('New: ${preview.count(ImportAction.add)}')),
            Chip(label: Text('Updated: ${preview.count(ImportAction.update)}')),
            Chip(
              label: Text(
                'Unchanged: ${preview.count(ImportAction.unchanged)}',
              ),
            ),
            Chip(
              backgroundColor: preview.errors.isEmpty
                  ? null
                  : cs.errorContainer,
              label: Text('Errors: ${preview.errors.length}'),
            ),
            Chip(label: Text('Warnings: ${preview.warnings.length}')),
          ],
        ),
        if (preview.errors.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Fix these in your sheet and paste again — nothing is imported '
            'while there are errors:',
            style: t.titleSmall?.copyWith(color: cs.error),
          ),
          for (final String e in preview.errors)
            SelectableText('• $e', style: TextStyle(color: cs.error)),
        ],
        if (preview.warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Warnings (${preview.warnings.length})'),
            children: [
              for (final String w in preview.warnings)
                Align(
                  alignment: Alignment.centerLeft,
                  child: SelectableText('• $w'),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Line')),
                DataColumn(label: Text('Action')),
                DataColumn(label: Text('Id')),
                DataColumn(label: Text('Latin')),
                DataColumn(label: Text('Ge\'ez')),
                DataColumn(label: Text('Gender')),
                DataColumn(label: Text('Meaning')),
              ],
              rows: [
                for (final ImportRow r in preview.rows.take(200))
                  DataRow(
                    cells: [
                      DataCell(Text('${r.line}')),
                      DataCell(Text(r.action.name)),
                      DataCell(Text(r.name.id)),
                      DataCell(Text(r.name.nameLatin)),
                      DataCell(Text(r.name.nameGeez)),
                      DataCell(Text(r.name.gender)),
                      DataCell(
                        SizedBox(
                          width: 280,
                          child: Text(
                            r.name.meaningEn,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (preview.rows.length > 200)
          Text(
            '…and ${preview.rows.length - 200} more rows',
            style: t.bodySmall,
          ),
      ],
    );
  }
}
