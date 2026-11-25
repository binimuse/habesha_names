import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/core/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const HabeshaNamesApp());
}
