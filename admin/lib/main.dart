import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme.dart';
import 'data/admin_repository.dart';
import 'firebase_options.dart';
import 'pages/auth_gate.dart';
import 'pages/import_page.dart';
import 'pages/name_edit_page.dart';
import 'services/admin_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: AdminFirebaseOptions.web);
  Get.put(AdminRepository(), permanent: true);
  Get.put(AdminAuth(), permanent: true);
  runApp(const AdminApp());
}

abstract final class AdminRoutes {
  static const String home = '/';
  static const String editName = '/name';
  static const String import = '/import';
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Habesha Names Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.light(),
      initialRoute: AdminRoutes.home,
      getPages: [
        GetPage(name: AdminRoutes.home, page: () => const AuthGate()),
        GetPage(
          name: AdminRoutes.import,
          page: () => const ImportPage(),
          binding: BindingsBuilder(() {
            Get.put(ImportController(Get.find(), Get.find()));
          }),
        ),
        GetPage(
          name: AdminRoutes.editName,
          page: () => const NameEditPage(),
          binding: BindingsBuilder(() {
            Get.put(NameEditController(Get.find(), Get.arguments));
          }),
        ),
      ],
    );
  }
}
