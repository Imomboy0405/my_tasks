import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';
import 'package:my_tasks/Application/Welcome/Start/View/start_page.dart';
import 'package:my_tasks/Data/Models/user_model.dart';
import 'package:my_tasks/Data/Services/db_service.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';
import 'package:my_tasks/Data/Services/theme_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final MainBloc mainBloc;
  bool darkMode = ThemeService.getTheme == ThemeMode.dark;
  String fullName = '';
  String dateSign = '';
  Language selectedLang = LangService.getLanguage;
  List<Language> lang = [
    Language.uz,
    Language.ru,
    Language.en,
  ];

  ProfileBloc({required this.mainBloc}) : super(ProfileInitialState(darkMode: false)) {
    on<InitialUserEvent>(initialUser);
    on<LanguageEvent>(pressLanguage);
    on<SelectLanguageEvent>(pressSelectLanguage);
    on<CancelEvent>(pressCancel);
    on<DoneEvent>(pressDone);
    on<DarkModeEvent>(pressDarkMode);
    on<SignOutEvent>(pressSignOut);
    on<ConfirmEvent>(pressConfirm);
    on<InfoEvent>(pressInfo);
  }

  void initialUser(InitialUserEvent event, Emitter<ProfileState> emit) async {
    darkMode = ThemeService.getTheme == ThemeMode.dark;
    mainBloc.darkMode = darkMode;
    selectedLang = LangService.getLanguage;
    String? str = await DBService.loadData(StorageKey.user);
    dateSign = userFromJson(str!).createdTime!;

    emit(ProfileInitialState(darkMode: darkMode));
  }

  void pressLanguage(LanguageEvent event, Emitter<ProfileState> emit) {
    mainBloc.add(MainHideBottomNavigationBarEvent());
    emit(ProfileLangState(lang: selectedLang));
  }

  void pressSelectLanguage(SelectLanguageEvent event, Emitter<ProfileState> emit) {
    selectedLang = event.lang;
    emit(ProfileLangState(lang: selectedLang));
  }

  void pressCancel(CancelEvent event, Emitter<ProfileState> emit) {
    selectedLang = LangService.getLanguage;
    mainBloc.add(MainLanguageEvent());
    emit(ProfileInitialState(darkMode: darkMode));
  }

  Future<void> pressDone(DoneEvent event, Emitter<ProfileState> emit) async {
    await LangService.language(selectedLang);
    mainBloc.add(MainLanguageEvent());
    emit(ProfileInitialState(darkMode: darkMode));
  }

  Future<void> pressDarkMode(DarkModeEvent event, Emitter<ProfileState> emit) async {
    darkMode = event.darkMode;
    await ThemeService.theme(darkMode ? ThemeMode.dark : ThemeMode.light);
    mainBloc.add(MainThemeEvent());
    emit(ProfileInitialState(darkMode: darkMode));
  }

  void pressSignOut(SignOutEvent event, Emitter<ProfileState> emit) {
    mainBloc.add(MainHideBottomNavigationBarEvent());
    emit(ProfileSignOutState());
  }

  void pressConfirm(ConfirmEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    await DBService.deleteData(StorageKey.user);
    await DBService.deleteData(StorageKey.task);
    if (event.context.mounted) {
      Navigator.pushNamedAndRemoveUntil(event.context, StartPage.id, (route) => false);
    }
  }

  void pressInfo(InfoEvent event, Emitter<ProfileState> emit) {
    mainBloc.add(MainHideBottomNavigationBarEvent());
    emit(ProfileInfoState());
  }
}
