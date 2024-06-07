import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tasks/Application/Main/View/main_page.dart';
import 'package:my_tasks/Data/Models/user_model.dart';
import 'package:my_tasks/Data/Services/db_service.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';
import 'package:my_tasks/Data/Services/util_service.dart';

part 'start_event.dart';
part 'start_state.dart';

class StartBloc extends Bloc<StartEvent, StartState> {
  Language selectedLang = LangService.getLanguage;
  List<Language> lang = [
    Language.uz,
    Language.ru,
    Language.en,
  ];

  StartBloc() : super(StartInitialState()) {
    on<FlagEvent>(pressFlagButton);
    on<NextEvent>(pressNextButton);
    on<SelectLanguageEvent>(pressLanguageButton);
  }

  void pressFlagButton(FlagEvent event, Emitter emit) {
    emit(StartFlagState());
  }

  void pressNextButton(NextEvent event, Emitter emit) async {
    try {
      UserModel userModel = UserModel(uId: 'user${DateTime.now()}', createdTime: DateTime.now().toString().substring(0, 16));
      await DBService.saveUser(userModel);

      if (event.context.mounted) {
        Navigator.pushReplacementNamed(event.context, MainPage.id);
      }
    } catch (e) {
      if (event.context.mounted) {
        Utils.mySnackBar(txt: e.toString(), context: event.context, errorState: true);
      }
    }
  }

  Future<void> pressLanguageButton(SelectLanguageEvent event, Emitter emit) async {
    await LangService.language(event.lang);
    selectedLang = event.lang;
    emit(StartFlagState());
    emit(StartInitialState());
  }
}
