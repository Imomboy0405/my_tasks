import 'package:get_it/get_it.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerSingleton<MainBloc>(MainBloc());
}