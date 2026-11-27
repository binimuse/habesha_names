import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/admin_auth.dart';
import 'names_page.dart';
import 'reports_page.dart';
import 'suggestions_page.dart';
import 'users_page.dart';
import 'waitlist_page.dart';

class AdminShellController extends GetxController {
  final RxInt index = 0.obs;
}

/// Side rail: Names · Reports · Suggestions · AI waitlist · Users.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminShellController c = Get.put(AdminShellController());
    final AdminAuth auth = Get.find();
    return Scaffold(
      body: Row(
        children: [
          Obx(
            () => NavigationRail(
              selectedIndex: c.index.value,
              onDestinationSelected: c.index.call,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircleAvatar(child: Text('ሀ')),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      tooltip: 'Sign out ${auth.email.value ?? ''}',
                      onPressed: auth.signOut,
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.badge_outlined),
                  selectedIcon: Icon(Icons.badge),
                  label: Text('Names'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.flag_outlined),
                  selectedIcon: Icon(Icons.flag),
                  label: Text('Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.lightbulb_outline),
                  selectedIcon: Icon(Icons.lightbulb),
                  label: Text('Suggestions'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome),
                  label: Text('AI waitlist'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Users'),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: c.index.value,
                children: const [
                  NamesPage(),
                  ReportsPage(),
                  SuggestionsPage(),
                  WaitlistPage(),
                  UsersPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
