import 'package:flutter/material.dart';
import 'package:my_tasks/app.dart';

import 'Data/Services/locator_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupLocator();

  runApp(MyTasks());
}