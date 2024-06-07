import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_tasks/Data/Models/task_model.dart';
import 'package:my_tasks/Data/Models/user_model.dart';
import 'package:my_tasks/Data/Services/theme_service.dart' as theme;
import 'package:my_tasks/Data/Services/lang_service.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  bool darkMode = theme.ThemeService.getTheme == theme.ThemeMode.dark;
  Language language = LangService.getLanguage;

  int currentScreen = 0;
  int oldScreen = 0;
  bool menuButtonPressed = false;
  List<TaskModel> tasks = [];
  List<TaskModel> filterTasks = [];

  final List<AssetImage> listOfMenuIcons = [
    const AssetImage('assets/icons/ic_menu_task_outlined.png'),
    const AssetImage('assets/icons/ic_menu_new_outlined.png'),
    const AssetImage('assets/icons/ic_menu_profile_outlined.png'),
    const AssetImage('assets/icons/ic_menu_task.png'),
    const AssetImage('assets/icons/ic_menu_new.png'),
    const AssetImage('assets/icons/ic_menu_profile.png'),
  ];

  final List<String> listOfMenuTexts = [
    'tasks',
    'new',
    'profile',
  ];
  PageController controller = PageController(keepPage: true, initialPage: 0);

  late UserModel userModel;
  int selectedDay = DateTime.now().day;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  double dayControllerPixels = 0;

  MainBloc() : super(MainInitialState(
    screen: 0,
    lang: LangService.getLanguage,
    darkMode: theme.ThemeService.getTheme == theme.ThemeMode.dark,
    selectedDay: DateTime.now().day,
    selectedMonth: DateTime.now().month,
    selectedYear: DateTime.now().year,
    dayControllerPixels: 0,
  )) {
    on<MainScrollMenuEvent>(scrollMenu);
    on<MainMenuButtonEvent>(pressMenuButton);
    on<MainHideBottomNavigationBarEvent>(hideBottomNavigationBar);
    on<MainLanguageEvent>(languageUpdate);
    on<MainThemeEvent>(themeUpdate);
  }

  void emitComfort(Emitter<MainState> emit) {
    emit(MainInitialState(
      screen: currentScreen,
      lang: language,
      darkMode: darkMode,
      selectedDay: selectedDay,
      selectedMonth: selectedMonth,
      selectedYear: selectedYear,
      dayControllerPixels: dayControllerPixels,
    ));
  }

  void listen() {
    if ((!menuButtonPressed) &&
        controller.page! - controller.page!.truncate() < 0.2
        || controller.page! - controller.page!.truncate() > 0.8){
      currentScreen = controller.page!.round();
    }

    if (currentScreen != oldScreen && !menuButtonPressed) {
      oldScreen = currentScreen;
      add(MainScrollMenuEvent(index: currentScreen));
    }
  }

  Future<void> pressMenuButton(MainMenuButtonEvent event, Emitter<MainState> emit) async {
    menuButtonPressed = true;
    if(oldScreen < event.index) {
      currentScreen = event.index;
      await controller.animateToPage(
          currentScreen,
          duration: Duration(milliseconds: (currentScreen - oldScreen)  * 50 + 150),
          curve: Curves.linear);
      emitComfort(emit);
    }
    else if(event.index < oldScreen) {
      currentScreen = event.index;
      await controller.animateToPage(
          currentScreen,
          duration: Duration(milliseconds: (oldScreen - currentScreen)  * 50 + 150),
          curve: Curves.linear);
      currentScreen--;
      emitComfort(emit);
    }
    oldScreen = currentScreen;
    menuButtonPressed = false;
  }

  Future<void> scrollMenu(MainScrollMenuEvent event, Emitter<MainState> emit) async {
    await controller.animateToPage(currentScreen, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    emitComfort(emit);
  }

  void hideBottomNavigationBar(MainHideBottomNavigationBarEvent event, Emitter<MainState> emit) {
    emit(MainHideBottomNavigationBarState());
  }

  void languageUpdate(MainLanguageEvent event, Emitter<MainState> emit) {
    language = LangService.getLanguage;
    emitComfort(emit);
  }

  void themeUpdate(MainThemeEvent event, Emitter<MainState> emit) {
    darkMode = theme.ThemeService.getTheme == theme.ThemeMode.dark;
    emitComfort(emit);
  }
}
