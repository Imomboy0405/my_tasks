import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';
import 'package:my_tasks/Data/Models/task_model.dart';
import 'package:my_tasks/Data/Services/db_service.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';
import 'package:my_tasks/Data/Services/util_service.dart';

part 'single_event.dart';
part 'single_state.dart';

class SingleBloc extends Bloc<SingleEvent, SingleState> {
  final MainBloc mainBloc;
  bool completed = false;
  bool history = false;
  bool initial = true;
  ScrollController controller = ScrollController();
  late TaskModel taskModel;

  SingleBloc({
    required this.mainBloc,
    required this.taskModel,
  }) : super(SingleInitialState(
          completed: false, taskModel: taskModel,
        )) {
    on<CompletedButtonEvent>(pressCompletedButton);
    on<DeleteButtonEvent>(pressDeleteButton);
    on<DeleteConfirmEvent>(pressDeleteConfirm);
    on<DeleteCancelEvent>(pressDeleteCancel);
    on<CreateButtonEvent>(pressCreateButton);
  }

  Future<void> pressCompletedButton(CompletedButtonEvent event, Emitter<SingleState> emit) async {
      if (taskModel.status! == TaskStatus.inProcess && !initial) {
        emit(SingleLoadingState());
        completed = true;
        mainBloc.tasks.remove(taskModel);
        mainBloc.filterTasks.remove(taskModel);
        taskModel.status = TaskStatus.completed;
        mainBloc.tasks.add(taskModel);
        await DBService.saveTasks(mainBloc.tasks);
        if (event.context.mounted) {
          Utils.mySnackBar(txt: 'task_completed'.tr(), context: event.context);
        }
      }
      if (taskModel.status! == TaskStatus.completed) {
        completed = true;
      }
      initial = false;
      emit(SingleInitialState(
        completed: completed,
        taskModel: taskModel,
      ));
  }

  Future<void> pressDeleteButton(DeleteButtonEvent event, Emitter<SingleState> emit) async {
    emit(SingleDeleteState());
  }

  Future<void> pressDeleteCancel(DeleteCancelEvent event, Emitter<SingleState> emit) async {
    emit(SingleInitialState(completed: completed, taskModel: taskModel));
  }

  Future<void> pressDeleteConfirm(DeleteConfirmEvent event, Emitter<SingleState> emit) async {
    emit(SingleLoadingState());
    try {
      mainBloc.tasks.remove(taskModel);
      mainBloc.filterTasks.remove(taskModel);
      await DBService.saveTasks(mainBloc.tasks);
      if (event.context.mounted) {
        Utils.mySnackBar(txt: 'deleting_complete'.tr(), context: event.context);
        Navigator.pop(event.context, taskModel);
      }
    } catch (e) {
      if (event.context.mounted) {
        Utils.mySnackBar(txt: e.toString(), context: event.context, errorState: true);
      }
    }
  }

  void pressCreateButton(CreateButtonEvent event, Emitter<SingleState> emit) {
    Navigator.pop(event.context);
    mainBloc.add(MainMenuButtonEvent(index: 1));
  }
}
