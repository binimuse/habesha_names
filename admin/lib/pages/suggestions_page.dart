import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/admin_repository.dart';
import '../main.dart';
import 'name_edit_page.dart';
import 'widgets/state_views.dart';

class SuggestionsController extends GetxController {
  SuggestionsController(this._repo);

  final AdminRepository _repo;
  StreamSubscription<List<Suggestion>>? _sub;

  final RxList<Suggestion> items = <Suggestion>[].obs;
  final RxBool loading = true.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    _sub?.cancel();
    loading.value = true;
    error.value = null;
    _sub = _repo.watchSuggestions().listen(
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

  /// Opens the name form prefilled; the suggestion is removed on save.
  void approve(Suggestion s) => Get.toNamed<void>(
    AdminRoutes.editName,
    arguments: NameEditArgs(suggestion: s),
  );

  Future<void> dismiss(Suggestion s) async {
    try {
      await _repo.deleteSuggestion(s.id);
    } catch (e) {
      Get.snackbar('Could not dismiss', '$e');
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

class SuggestionsPage extends StatelessWidget {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SuggestionsController c = Get.put(SuggestionsController(Get.find()));
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text('Suggestions (${c.items.length})'))),
      body: Obx(() {
        if (c.loading.value) return const LoadingView();
        if (c.error.value != null) {
          return ErrorView(message: c.error.value!, onRetry: c.load);
        }
        if (c.items.isEmpty) {
          return const EmptyView(message: 'No suggestions from users yet.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: c.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _SuggestionCard(item: c.items[i]),
        );
      }),
    );
  }
}

class _SuggestionCard extends GetView<SuggestionsController> {
  const _SuggestionCard({required this.item});

  final Suggestion item;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      item.nameLatin,
                      item.nameGeez,
                    ].where((s) => s.isNotEmpty).join(' · '),
                    style: t.titleMedium,
                  ),
                  if (item.meaning.isNotEmpty) Text(item.meaning),
                  if (item.note.isNotEmpty)
                    Text('Note: ${item.note}', style: t.bodySmall),
                  Text(
                    'UI ${item.language} · '
                    '${item.createdAt?.toLocal().toString().substring(0, 16) ?? ''}',
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => controller.approve(item),
                  child: const Text('Add as name'),
                ),
                OutlinedButton(
                  onPressed: () => controller.dismiss(item),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
