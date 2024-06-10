import 'package:flutter/material.dart';
import 'package:my_tasks/Data/Services/notification_service.dart';
import 'package:my_tasks/app.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'Data/Services/locator_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await NotificationService.initialize();
  await setupLocator();

  runApp(MyTasks());
}
