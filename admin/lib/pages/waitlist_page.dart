import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../data/admin_repository.dart';
import 'widgets/state_views.dart';

class WaitlistController extends GetxController {
  WaitlistController(this._repo);

  final AdminRepository _repo;
  StreamSubscription<List<WaitlistEntry>>? _sub;

  final RxList<WaitlistEntry> items = <WaitlistEntry>[].obs;
  final RxBool loading = true.obs;
  final RxnString error = RxnString();

  int countFor(String feature) =>
      items.where((e) => e.features.contains(feature)).length;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    _sub?.cancel();
    loading.value = true;
    error.value = null;
    _sub = _repo.watchWaitlist().listen(
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

  /// CSV of all entries, copied to the clipboard (paste into a sheet).
  Future<void> copyCsv() async {
    String q(String s) => '"${s.replaceAll('"', '""')}"';
    final StringBuffer b = StringBuffer('created_at,language,features,text\n');
    for (final WaitlistEntry e in items) {
      b.writeln(
        [
          q(e.createdAt?.toUtc().toIso8601String() ?? ''),
          q(e.language),
          q(e.features.join(' ')),
          q(e.text),
        ].join(','),
      );
    }
    await Clipboard.setData(ClipboardData(text: b.toString()));
    Get.snackbar('Copied', '${items.length} rows copied as CSV.');
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

class WaitlistPage extends StatelessWidget {
  const WaitlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final WaitlistController c = Get.put(WaitlistController(Get.find()));
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('AI waitlist (${c.items.length})')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Obx(
              () => OutlinedButton.icon(
                onPressed: c.items.isEmpty ? null : c.copyCsv,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copy CSV'),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (c.loading.value) return const LoadingView();
        if (c.error.value != null) {
          return ErrorView(message: c.error.value!, onRetry: c.load);
        }
        if (c.items.isEmpty) {
          return const EmptyView(
            message: 'Nobody has joined the waitlist yet.',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              children: [
                Chip(label: Text('Name finder: ${c.countFor('name_finder')}')),
                Chip(
                  label: Text('Face preview: ${c.countFor('face_preview')}'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final WaitlistEntry e in c.items)
              Card(
                child: ListTile(
                  title: Text(e.text.isEmpty ? '(no text)' : e.text),
                  subtitle: Text(
                    '${e.features.join(', ')} · ${e.language} · '
                    '${e.createdAt?.toLocal().toString().substring(0, 16) ?? ''}',
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
