import 'package:flutter/material.dart';
import 'package:my_tasks/Application/Menus/New/View/new_page.dart';
import 'package:my_tasks/Application/Menus/Profile/View/profile_page.dart';
import 'package:my_tasks/Application/Menus/Tasks/View/tasks_page.dart';
import 'Application/Main/View/main_page.dart';
import 'Application/Welcome/Splash/splash_page.dart';
import 'Application/Welcome/Start/View/start_page.dart';
import 'Configuration/app_colors.dart';
import 'Data/Services/db_service.dart';
import 'Data/Services/init_service.dart';

class MyTasks extends StatelessWidget {
  final Future _initFuture = Init.initialize();
  MyTasks({super.key});

  Widget _startPage() {
    return FutureBuilder(
      future: DBService.loadData(StorageKey.user),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainPage();
        } else {
          return const StartPage();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'My Tasks',
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ru', 'RU'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.blue),
        canvasColor: AppColors.transparentGray,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _startPage();
          } else {
            return const SplashPage();
          }
        },
      ),
      routes: {
        StartPage.id: (context) => const StartPage(),
        TasksPage.id: (context) => const TasksPage(),
        ProfilePage.id: (context) => const ProfilePage(),
        NewPage.id: (context) => const NewPage(),
        MainPage.id: (context) => const MainPage(),
      },
    );
  }
}
