import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';
import 'package:my_tasks/Application/Menus/View/menu_widgets.dart';
import 'package:my_tasks/Data/Models/task_model.dart';
import 'package:my_tasks/Data/Services/db_service.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';
import 'package:my_tasks/Data/Services/util_service.dart';


part 'new_event.dart';
part 'new_state.dart';

class NewBloc extends Bloc<NewEvent, NewState> {
  MainBloc mainBloc;
  bool suffixTitle = false;
  bool suffixContent = false;
  DateTime startDate = DateTime.now();
  DateTime? endDate;
  int day = 0;
  int hour = 0;
  int minute = 0;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  FocusNode focusTitle = FocusNode();
  FocusNode focusContent = FocusNode();

  NewBloc({required this.mainBloc}) : super(NewInitialState()) {
    on<TaskChange>(taskChange);
    on<TaskSubmitted>(taskSubmitted);
    on<TaskSave>(pressTaskSave);
    on<ShowDatePickerEvent>(pressDatePicker);
  }

  void taskChange(TaskChange event, Emitter<NewState> emit) {
    suffixTitle = titleController.text.replaceAll(' ', '').isNotEmpty;
    suffixContent = contentController.text.replaceAll(' ', '').isNotEmpty;

    emit(NewTaskState(
      suffixTitle: suffixTitle,
      borderTitle: focusTitle.hasFocus || titleController.text.isNotEmpty,
      suffixContent: suffixContent,
      borderContent: focusContent.hasFocus || contentController.text.isNotEmpty,
      selectedDate: startDate,
      selectedDateTo: endDate ?? startDate,
      day: day,
      hour: hour,
      minute: minute,
    ));
  }

  Future<void> taskSubmitted(TaskSubmitted event, Emitter<NewState> emit) async {
    if (event.title) {
      focusTitle.unfocus();
      await Future.delayed(const Duration(milliseconds: 30));
      focusContent.requestFocus();
    } else {
      focusContent.unfocus();
    }

    if (titleController.text.isNotEmpty) {
      titleController.text = titleController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    }
    suffixTitle = titleController.text.replaceAll(' ', '').isNotEmpty;
    suffixContent = contentController.text.replaceAll(' ', '').isNotEmpty;

    emit(NewTaskState(
      suffixTitle: suffixTitle,
      borderTitle: focusTitle.hasFocus || titleController.text.isNotEmpty,
      suffixContent: suffixContent,
      borderContent: focusContent.hasFocus || contentController.text.isNotEmpty,
      selectedDate: startDate,
      selectedDateTo: endDate ?? startDate,
      day: day,
      hour: hour,
      minute: minute,
    ));
  }

  Future<void> pressDatePicker(ShowDatePickerEvent event, Emitter<NewState> emit) async {
    DateTime? picked;
    focusTitle.unfocus();
    focusContent.unfocus();
    if (event.toDate) {
      picked = await showDatePicker(
          context: event.context,
          initialDate: endDate ?? DateTime(startDate.year, startDate.month, startDate.day + 1) ,
          firstDate: DateTime(startDate.year, startDate.month, startDate.day + 1),
          lastDate: DateTime.parse('2030-12-31'),
          builder: (BuildContext context, Widget? child) {
            return myDatePickerTheme(child);
          });
    } else {
      picked = await showDatePicker(
          context: event.context,
          initialDate: startDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.parse('2030-12-31'),
          builder: (BuildContext context, Widget? child) {
            return myDatePickerTheme(child);
          });
      if (picked != null) {
        endDate = null;
      }
    }

    if (picked != null) {
      TimeOfDay? pickedTime;
      if (event.context.mounted) {
        pickedTime = await showTimePicker(
            context: event.context,
            initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute + 1),
            builder: (BuildContext context, Widget? child) {
              return myDatePickerTheme(child);
            }
        );
      }

      if (pickedTime != null) {
        if (event.toDate) {
          endDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
          day = endDate!.difference(startDate).inDays;
          hour = endDate!.difference(startDate).inHours % 24;
          minute = endDate!.difference(startDate).inMinutes % 60;
        } else {
          if (!DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute).isBefore(DateTime.now())) {
            startDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
            day = 0;
            hour = 0;
            minute = 0;
          } else {
            if (event.context.mounted) {
              Utils.mySnackBar(txt: 'error_time'.tr(), context: event.context, errorState: true);
            }
          }
        }
      }
    }
    emit(NewTaskState(
      suffixTitle: suffixTitle,
      borderTitle: focusTitle.hasFocus || titleController.text.isNotEmpty,
      suffixContent: suffixContent,
      borderContent: focusContent.hasFocus || contentController.text.isNotEmpty,
      selectedDate: startDate,
      selectedDateTo: endDate ?? startDate,
      day: day,
      hour: hour,
      minute: minute,
    ));
  }

  void pressTaskSave(TaskSave event, Emitter<NewState> emit) async {
    focusTitle.unfocus();
    focusContent.unfocus();
    emit(NewTaskLoadingState());
    try {
      TaskModel task = TaskModel(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        createdTime: DateTime.now(),
        startDate: startDate,
        endDate: endDate,
        status: TaskStatus.inProcess,
        id: 'task_${DateTime.now().toString()}',
      );
      mainBloc.tasks.insert(0, task);
      await DBService.saveTasks(mainBloc.tasks);
      endDate = null;
      titleController.clear();
      contentController.clear();
      day = 0;
      hour = 0;
      minute = 0;
      if (event.context.mounted) {
        Utils.mySnackBar(txt: 'task_saved'.tr(), context: event.context);
      }
      emit(NewInitialState());
    } catch (e) {
      debugPrint(e.toString());
      if (event.context.mounted) {
        Utils.mySnackBar(txt: e.toString(), context: event.context, errorState: true);
      }
    }
  }
}
