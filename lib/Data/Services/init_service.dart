import 'package:my_tasks/Data/Services/theme_service.dart';

import 'lang_service.dart';
import 'notification_service.dart';

class Init {
  static Future initialize() async {
    await _loading();
  }

  static _loading() async {
    await LangService.currentLanguage();
    await ThemeService.currentTheme();
    NotificationService.initialize();
    await Future.delayed(const Duration(seconds: 1));
  }
}