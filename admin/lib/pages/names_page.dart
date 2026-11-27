import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme.dart';
import '../data/admin_name.dart';
import '../data/admin_repository.dart';
import '../main.dart';
import 'name_edit_page.dart';
import 'widgets/state_views.dart';

/// Status filter: null = everything except deleted.
enum StatusFilter { active, published, drafts, changed, deleted }

class NamesController extends GetxController {
  NamesController(this._repo);

  final AdminRepository _repo;
  final List<StreamSubscription<List<AdminName>>> _subs = [];
  List<AdminName> _live = const [];
  List<AdminName> _drafts = const [];
  int _pending = 2; // first snapshot from both collections

  final RxList<NameEntry> all = <NameEntry>[].obs;
  final RxBool loading = true.obs;
  final RxBool publishing = false.obs;
  final RxnString error = RxnString();
  final RxString query = ''.obs;
  final Rx<StatusFilter> status = StatusFilter.active.obs;
  final RxnString gender = RxnString();

  int count(NameStatus s) => all.where((e) => e.status == s).length;

  /// Names phones can see (published, incl. those with pending changes).
  int get liveCount => count(NameStatus.published) + count(NameStatus.changed);

  /// Drafts and pending edits — what "Publish all" would push live.
  List<AdminName> get unpublished => [
    for (final NameEntry e in all)
      if (e.draft != null) e.draft!,
  ];

  List<NameEntry> get visible {
    final String q = query.value.trim().toLowerCase();
    return [
      for (final NameEntry e in all)
        if (_matchesStatus(e.status) &&
            (gender.value == null || e.current.gender == gender.value) &&
            (q.isEmpty ||
                e.current.nameLatin.toLowerCase().contains(q) ||
                e.current.nameGeez.contains(q) ||
                e.id.contains(q) ||
                e.current.meaningEn.toLowerCase().contains(q)))
          e,
    ];
  }

  bool _matchesStatus(NameStatus s) => switch (status.value) {
    StatusFilter.active => s != NameStatus.deleted,
    StatusFilter.published =>
      s == NameStatus.published || s == NameStatus.changed,
    StatusFilter.drafts => s == NameStatus.draft,
    StatusFilter.changed => s == NameStatus.changed,
    StatusFilter.deleted => s == NameStatus.deleted,
  };

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    _cancel();
    loading.value = true;
    error.value = null;
    _pending = 2;
    void onError(Object e) {
      error.value = '$e';
      loading.value = false;
    }

    _subs
      ..add(
        _repo.watchNames().listen((l) {
          _live = l;
          _changed();
        }, onError: onError),
      )
      ..add(
        _repo.watchDrafts().listen((l) {
          _drafts = l;
          _changed();
        }, onError: onError),
      );
  }

  void _changed() {
    all.assignAll(NameEntry.merge(_live, _drafts));
    if (_pending > 0) _pending--;
    if (_pending == 0) loading.value = false;
  }

  void add() => Get.toNamed<void>(AdminRoutes.editName);

  void bulkImport() => Get.toNamed<void>(AdminRoutes.import);

  void edit(NameEntry e) => Get.toNamed<void>(
    AdminRoutes.editName,
    arguments: NameEditArgs(id: e.id),
  );

  Future<void> toggleDeleted(NameEntry e) async {
    final AdminName? live = e.published;
    try {
      if (live == null) {
        await _repo.discardDraft(e.id); // draft only: just remove it
      } else {
        await _repo.setDeleted(e.id, deleted: !live.deleted);
      }
    } catch (err) {
      Get.snackbar('Could not update ${e.current.nameLatin}', '$err');
    }
  }

  Future<void> publishAll() async {
    final List<AdminName> drafts = unpublished;
    if (drafts.isEmpty || publishing.value) return;
    final bool? ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Publish ${drafts.length} drafts?'),
        content: const Text(
          'They become visible in the app on each phone\'s next sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    publishing.value = true;
    try {
      await _repo.publishAll(drafts);
      Get.snackbar('Published', '${drafts.length} names are now live.');
    } catch (e) {
      Get.snackbar('Publish failed', '$e');
    } finally {
      publishing.value = false;
    }
  }

  void _cancel() {
    for (final StreamSubscription<List<AdminName>> s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  @override
  void onClose() {
    _cancel();
    super.onClose();
  }
}

class NamesPage extends StatelessWidget {
  const NamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NamesController c = Get.put(NamesController(Get.find()));
    // Phone-width windows: icon buttons so the app bar never overflows.
    final bool narrow = MediaQuery.sizeOf(context).width < 640;
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            narrow
                ? 'Names (${c.liveCount})'
                : 'Names · ${c.liveCount} live · '
                      '${c.unpublished.length} unpublished',
          ),
        ),
        actions: [
          Obx(() {
            final int n = c.unpublished.length;
            if (n == 0) return const SizedBox.shrink();
            final VoidCallback? onPressed = c.publishing.value
                ? null
                : c.publishAll;
            return narrow
                ? IconButton(
                    tooltip: 'Publish all $n drafts',
                    onPressed: onPressed,
                    icon: Badge(
                      label: Text('$n'),
                      child: const Icon(Icons.publish),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilledButton.tonalIcon(
                      onPressed: onPressed,
                      icon: const Icon(Icons.publish),
                      label: Text('Publish all ($n)'),
                    ),
                  );
          }),
          if (narrow) ...[
            IconButton(
              tooltip: 'Bulk import',
              onPressed: c.bulkImport,
              icon: const Icon(Icons.upload_file_outlined),
            ),
            IconButton.filled(
              tooltip: 'Add name',
              onPressed: c.add,
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 8),
          ] else ...[
            OutlinedButton.icon(
              onPressed: c.bulkImport,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Bulk import'),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: c.add,
                icon: const Icon(Icons.add),
                label: const Text('Add name'),
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          const _Filters(),
          Expanded(
            child: Obx(() {
              if (c.loading.value) return const LoadingView();
              if (c.error.value != null) {
                return ErrorView(message: c.error.value!, onRetry: c.load);
              }
              final List<NameEntry> list = c.visible;
              if (list.isEmpty) {
                return const EmptyView(message: 'No names match.');
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _NameRow(entry: list[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Filters extends GetView<NamesController> {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              onChanged: controller.query.call,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search Latin, Ge\'ez, id or meaning',
              ),
            ),
          ),
          SizedBox(
            width: 240,
            child: Obx(
              () => DropdownButton<StatusFilter>(
                isExpanded: true,
                value: controller.status.value,
                onChanged: (v) => controller.status.value = v!,
                items: [
                  const DropdownMenuItem(
                    value: StatusFilter.active,
                    child: Text('All (not deleted)'),
                  ),
                  DropdownMenuItem(
                    value: StatusFilter.published,
                    child: Text('Published (${controller.liveCount})'),
                  ),
                  DropdownMenuItem(
                    value: StatusFilter.drafts,
                    child: Text(
                      'Drafts (${controller.count(NameStatus.draft)})',
                    ),
                  ),
                  DropdownMenuItem(
                    value: StatusFilter.changed,
                    child: Text(
                      'Unpublished changes '
                      '(${controller.count(NameStatus.changed)})',
                    ),
                  ),
                  DropdownMenuItem(
                    value: StatusFilter.deleted,
                    child: Text(
                      'Deleted (${controller.count(NameStatus.deleted)})',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => SegmentedButton<String?>(
              segments: const [
                ButtonSegment(value: null, label: Text('All')),
                ButtonSegment(value: 'girl', label: Text('Girl')),
                ButtonSegment(value: 'boy', label: Text('Boy')),
                ButtonSegment(value: 'unisex', label: Text('Unisex')),
              ],
              selected: {controller.gender.value},
              onSelectionChanged: (s) => controller.gender.value = s.first,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final NameStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = StatusColors.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        StatusColors.label(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _NameRow extends GetView<NamesController> {
  const _NameRow({required this.entry});

  final NameEntry entry;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final AdminName name = entry.current;
    final NameStatus status = entry.status;
    final bool deleted = status == NameStatus.deleted;
    return Opacity(
      opacity: deleted ? 0.5 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          onTap: () => controller.edit(entry),
          leading: CircleAvatar(
            backgroundColor: AdminColors.gender(name.gender),
            child: Text(
              name.nameGeez.isEmpty ? '?' : name.nameGeez.characters.first,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${name.nameLatin} · ${name.nameGeez}',
                style: t.titleMedium,
              ),
              _StatusChip(status),
            ],
          ),
          subtitle: Text(
            [
              name.gender,
              name.meaningEn,
            ].where((s) => s.isNotEmpty).join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (name.verified)
                const Tooltip(
                  message: 'Verified',
                  child: Icon(Icons.verified, color: AdminColors.gold),
                ),
              if (name.audioUrl != null)
                const Tooltip(
                  message: 'Has audio',
                  child: Icon(Icons.volume_up_outlined),
                ),
              IconButton(
                tooltip: switch (status) {
                  NameStatus.draft => 'Delete draft',
                  NameStatus.deleted => 'Restore',
                  _ => 'Delete from app',
                },
                onPressed: () => controller.toggleDeleted(entry),
                icon: Icon(
                  deleted
                      ? Icons.restore_from_trash_outlined
                      : Icons.delete_outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
