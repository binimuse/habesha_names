import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/theme.dart';
import '../services/callable.dart';
import 'widgets/state_views.dart';

/// One row from the `adminListUsers` callable.
class AppUser {
  const AppUser(this._m);

  final Map<String, dynamic> _m;

  String get uid => _m['uid'] as String;
  String? get email => _m['email'] as String?;
  bool get anonymous => _m['anonymous'] == true;
  bool get admin => _m['admin'] == true;
  bool get disabled => _m['disabled'] == true;
  DateTime? get created => _date('created');
  DateTime? get lastSeen => _date('lastSeen');
  int get favorites => (_m['favorites'] as num?)?.toInt() ?? 0;
  int get devices => (_m['devices'] as num?)?.toInt() ?? 0;
  List<String> get languages => [
    for (final Object? l in (_m['languages'] as List<dynamic>? ?? const []))
      if (l is String) l,
  ];
  String? get coupleCode => _m['coupleCode'] as String?;
  bool get linked => _m['linked'] == true;

  DateTime? _date(String k) =>
      _m[k] is String ? DateTime.tryParse(_m[k] as String)?.toLocal() : null;
}

class UsersController extends GetxController {
  final RxList<AppUser> users = <AppUser>[].obs;
  final RxMap<String, int> stats = <String, int>{}.obs;
  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxString filter = 'all'.obs; // all | email | linked | push
  final RxBool truncated = false.obs;

  String? get myUid => FirebaseAuth.instance.currentUser?.uid;

  List<AppUser> get visible => [
    for (final AppUser u in users)
      if (switch (filter.value) {
        'email' => !u.anonymous,
        'linked' => u.linked,
        'push' => u.devices > 0,
        _ => true,
      })
        u,
  ];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        await Callable.call('adminListUsers') as Map,
      );
      stats.assignAll({
        for (final MapEntry<dynamic, dynamic> e
            in (data['stats'] as Map).entries)
          '${e.key}': (e.value as num).toInt(),
      });
      users.assignAll([
        for (final Object? u in data['users'] as List<dynamic>)
          AppUser(Map<String, dynamic>.from(u! as Map)),
      ]);
      truncated.value = data['truncated'] == true;
    } on CallableException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = '$e';
    } finally {
      loading.value = false;
    }
  }

  Future<void> setUser(AppUser u, {bool? admin, bool? disabled}) async {
    try {
      await Callable.call('adminSetUser', {
        'uid': u.uid,
        'admin': ?admin,
        'disabled': ?disabled,
      });
      await load();
    } on CallableException catch (e) {
      Get.snackbar('Could not update user', e.message);
    }
  }

  Future<void> copyUid(AppUser u) async {
    await Clipboard.setData(ClipboardData(text: u.uid));
    Get.snackbar('Copied', u.uid);
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UsersController c = Get.put(UsersController());
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Users (${c.users.length})')),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: c.load,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (c.loading.value && c.users.isEmpty) return const LoadingView();
        if (c.error.value != null) {
          return ErrorView(message: c.error.value!, onRetry: c.load);
        }
        final List<AppUser> list = c.visible;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _StatsRow(),
            const SizedBox(height: 16),
            const _FilterRow(),
            if (c.truncated.value)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Showing the first 5,000 users.'),
              ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              const EmptyView(message: 'No users match this filter.')
            else
              for (final AppUser u in list) _UserCard(user: u),
          ],
        );
      }),
    );
  }
}

class _StatsRow extends GetView<UsersController> {
  const _StatsRow();

  static const List<(String, String, IconData)> _tiles = [
    ('users', 'Users', Icons.people_outline),
    ('activeThisWeek', 'Active 7 days', Icons.trending_up),
    ('withPush', 'Push enabled', Icons.notifications_active_outlined),
    ('favorites', 'Favorites', Icons.favorite_border),
    ('couplesLinked', 'Linked couples', Icons.favorite),
    ('matches', 'Matches', Icons.auto_awesome),
    ('names', 'Live names', Icons.badge_outlined),
    ('suggestions', 'Suggestions', Icons.lightbulb_outline),
    ('waitlist', 'AI waitlist', Icons.hourglass_empty),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final (String key, String label, IconData icon) in _tiles)
            SizedBox(
              width: 170,
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 20, color: AdminColors.terracotta),
                      const SizedBox(height: 6),
                      Text(
                        '${controller.stats[key] ?? 0}',
                        style: t.headlineSmall,
                      ),
                      Text(label, style: t.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterRow extends GetView<UsersController> {
  const _FilterRow();

  @override
  Widget build(BuildContext context) => Obx(
    () => SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'all', label: Text('All')),
        ButtonSegment(value: 'email', label: Text('Email accounts')),
        ButtonSegment(value: 'linked', label: Text('Linked')),
        ButtonSegment(value: 'push', label: Text('Push on')),
      ],
      selected: {controller.filter.value},
      onSelectionChanged: (s) => controller.filter.value = s.first,
    ),
  );
}

class _UserCard extends GetView<UsersController> {
  const _UserCard({required this.user});

  final AppUser user;

  String _when(DateTime? d) => d == null
      ? '—'
      : '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';
  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final bool isMe = user.uid == controller.myUid;
    final String title =
        user.email ?? 'Anonymous · ${user.uid.substring(0, 8)}…';
    return Opacity(
      opacity: user.disabled ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: user.admin
                    ? AdminColors.gold
                    : user.anonymous
                    ? AdminColors.unisex
                    : AdminColors.boy,
                child: Icon(
                  user.admin
                      ? Icons.shield_outlined
                      : user.anonymous
                      ? Icons.person_outline
                      : Icons.mail_outline,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(title, style: t.titleMedium),
                        if (isMe) const _Tag('You'),
                        if (user.admin) const _Tag('Admin'),
                        if (user.disabled) const _Tag('Disabled'),
                        if (user.linked) _Tag('Linked · ${user.coupleCode}'),
                        if (!user.linked && user.coupleCode != null)
                          _Tag('Waiting · ${user.coupleCode}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last seen ${_when(user.lastSeen)} · joined '
                      '${_when(user.created)} · ${user.favorites} favorites · '
                      '${user.devices == 0 ? 'no push' : '${user.devices} device(s) '
                                '(${user.languages.join('/')})'}',
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Actions',
                onSelected: (a) => switch (a) {
                  'copy' => controller.copyUid(user),
                  'admin' => controller.setUser(user, admin: !user.admin),
                  'disable' => controller.setUser(
                    user,
                    disabled: !user.disabled,
                  ),
                  _ => null,
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'copy', child: Text('Copy uid')),
                  if (!user.anonymous && !isMe)
                    PopupMenuItem(
                      value: 'admin',
                      child: Text(user.admin ? 'Remove admin' : 'Make admin'),
                    ),
                  if (!isMe)
                    PopupMenuItem(
                      value: 'disable',
                      child: Text(user.disabled ? 'Enable' : 'Disable'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
  );
}
