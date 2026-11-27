import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme.dart';
import '../data/admin_repository.dart';
import '../main.dart';
import 'name_edit_page.dart';
import 'widgets/state_views.dart';

class ReportsController extends GetxController {
  ReportsController(this._repo);

  final AdminRepository _repo;
  StreamSubscription<List<NameReport>>? _sub;

  final RxList<NameReport> items = <NameReport>[].obs;
  final RxBool loading = true.obs;
  final RxnString error = RxnString();

  /// open | resolved | dismissed | all
  final RxString filter = 'open'.obs;

  int get openCount => items.where((r) => r.isOpen).length;

  List<NameReport> get visible => [
    for (final NameReport r in items)
      if (filter.value == 'all' || r.status == filter.value) r,
  ];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    _sub?.cancel();
    loading.value = true;
    error.value = null;
    _sub = _repo.watchReports().listen(
      (list) {
        items.assignAll(list);
        loading.value = false;
      },
      onError: (Object e) {
        error.value = '$e';
        loading.value = false;
      },
    );
  }

  /// Opens the reported name in the editor with the report pinned on top.
  void openName(NameReport r) => Get.toNamed<void>(
    AdminRoutes.editName,
    arguments: NameEditArgs(id: r.nameId, report: r),
  );

  Future<void> setStatus(NameReport r, String status) async {
    try {
      await _repo.setReportStatus(r.id, status);
    } catch (e) {
      Get.snackbar('Could not update report', '$e');
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportsController c = Get.put(ReportsController(Get.find()));
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text('Reports (${c.openCount} open)'))),
      body: Obx(() {
        if (c.loading.value) return const LoadingView();
        if (c.error.value != null) {
          return ErrorView(message: c.error.value!, onRetry: c.load);
        }
        final List<NameReport> list = c.visible;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'open', label: Text('Open')),
                ButtonSegment(value: 'resolved', label: Text('Resolved')),
                ButtonSegment(value: 'dismissed', label: Text('Dismissed')),
                ButtonSegment(value: 'all', label: Text('All')),
              ],
              selected: {c.filter.value},
              onSelectionChanged: (s) => c.filter.value = s.first,
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              EmptyView(
                message: c.filter.value == 'open'
                    ? 'No open reports. Nice!'
                    : 'Nothing here.',
              )
            else
              for (final NameReport r in list) ReportCard(report: r),
          ],
        );
      }),
    );
  }
}

class ReportCard extends GetView<ReportsController> {
  const ReportCard({super.key, required this.report});

  final NameReport report;

  static Color statusColor(String s) => switch (s) {
    'resolved' => const Color(0xFF4E8A57),
    'dismissed' => const Color(0xFF9E9E9E),
    _ => AdminColors.terracotta,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final NameReport r = report;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${r.nameLatin} · ${r.nameGeez}', style: t.titleMedium),
                Chip(
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: statusColor(r.status)),
                  label: Text(r.status),
                ),
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
              'id ${r.nameId} · app in ${r.language} · '
              '${r.createdAt?.toLocal().toString().substring(0, 16) ?? ''}',
              style: t.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => controller.openName(r),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Open name & fix'),
                ),
                if (r.isOpen) ...[
                  OutlinedButton(
                    onPressed: () => controller.setStatus(r, 'resolved'),
                    child: const Text('Mark resolved'),
                  ),
                  TextButton(
                    onPressed: () => controller.setStatus(r, 'dismissed'),
                    child: const Text('Dismiss'),
                  ),
                ] else
                  TextButton(
                    onPressed: () => controller.setStatus(r, 'open'),
                    child: const Text('Reopen'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
