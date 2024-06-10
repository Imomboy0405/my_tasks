import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';
import 'package:my_tasks/Application/Menus/View/Single/View/single_page.dart';
import 'package:my_tasks/Configuration/app_data_time.dart';
import 'package:my_tasks/Data/Models/task_model.dart';
import 'package:my_tasks/Data/Models/user_model.dart';
import 'package:my_tasks/Data/Services/db_service.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';
import 'package:my_tasks/Data/Services/notification_service.dart';
import 'package:my_tasks/Data/Services/util_service.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final MainBloc mainBloc;
  bool initialDayFirst = true;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedDay = DateTime.now().day;
  List<String> monthNames = AppDateTime.monthNames;
  List<int> monthDays = AppDateTime.monthDays;

  ScrollController invoiceController = ScrollController();
  ScrollController dayController = ScrollController();
  bool dayControllerLeftDone = true;
  bool dayControllerRightDone = true;

  List<TaskModel> filterTasks = [];
  bool filterEnabled = false;
  bool statusInProcess = false;
  bool statusCompleted = false;
  bool statusNotCompleted = false;
  bool statusInProcessOld = false;
  bool statusCompletedOld = false;
  bool statusNotCompletedOld = false;

  TasksBloc({required this.mainBloc})
      : super(TasksInitialState(
          day: DateTime.now().day,
          month: DateTime.now().month,
          filterTasks: const [],
          mainFilterTasks: mainBloc.filterTasks,
        )) {
    on<InitialDayControllerEvent>(initialDayButtonController);
    on<ListenEvent>(listenDayButtonsController);
    on<FilterEvent>(pressFilter);
    on<MonthButtonEvent>(pressMonthButton);
    on<DayButtonEvent>(pressDayButton);
    on<OnReorderEvent>(onReorder);
    on<SinglePageEvent>(pushSinglePage);
    on<CancelFilterEvent>(pressCancelFilter);
    on<ApplyFilterEvent>(pressApplyFilter);
    on<StatusFilterEvent>(pressStatusFilter);
    on<DeleteEvent>(deleting);
    on<RefreshEvent>(refresh);
  }

  void refresh(RefreshEvent event, Emitter<TasksState> emit) {
    updateFilter();
    emit(TasksInitialState(
      month: selectedMonth,
      day: selectedDay,
      filterTasks: filterTasks,
      mainFilterTasks: mainBloc.filterTasks,
    ));
  }

  Future<void> initialDayButtonController(InitialDayControllerEvent event, Emitter<TasksState> emit) async {
    if (initialDayFirst) {
      initialDayFirst = false;
      int currentMonthDayMax = AppDateTime.monthDays[DateTime.now().month - 1] == 28 && DateTime.now().year == 2024
          ? 29
          : AppDateTime.monthDays[DateTime.now().month - 1];

      double position = currentMonthDayMax - selectedDay < event.width ~/ 62
          ? ((currentMonthDayMax - (event.width ~/ 62)).toDouble()) * 62 - event.width % 62
          : (selectedDay.toDouble() - 1) * 62;
      dayController.animateTo(position, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

      String? json = await DBService.loadData(StorageKey.user);
      mainBloc.userModel = userFromJson(json!);
      json = null;
      json = await DBService.loadData(StorageKey.task);
      if (json != null) {
        mainBloc.tasks = tasksFromJson(json);
      } else {
        mainBloc.tasks = [];
      }
      await updateNotCompleted();
    }
  }

  Future<void> updateNotCompleted() async {
    for (var model in mainBloc.tasks) {
      if (model.status == TaskStatus.inProcess) {
        // if (model.endDate!.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1))) {
        //   NotificationService.showNotification('an_unfulfilled_task'.tr(), model.title!, 10, model.hashCode);
        //   print(model.title);
        // }
        if (model.endDate!.isBefore(DateTime.now())) {
          int i = mainBloc.tasks.indexOf(model);
          model.status = TaskStatus.notCompleted;
          mainBloc.tasks.removeAt(i);
          mainBloc.tasks.insert(i, model);
        }
      }
    }
    await DBService.saveTasks(mainBloc.tasks);
  }

  void pressFilter(FilterEvent event, Emitter<TasksState> emit) {
    mainBloc.add(MainHideBottomNavigationBarEvent());

    emit(TasksFilterState(
      completed: statusCompleted,
      inProcess: statusInProcess,
      notCompleted: statusNotCompleted,
    ));
  }

  void pressMonthButton(MonthButtonEvent event, Emitter<TasksState> emit) {
    if (event.left) {
      if (selectedMonth == 1) {
        selectedMonth = 12;
        selectedYear--;
      } else {
        selectedMonth--;
      }
      selectedDay = monthDays[selectedMonth - 1] == 28 && selectedYear == 2024 ? 29 : monthDays[selectedMonth - 1];
      dayController.jumpTo(selectedDay * 62 - event.width);
    } else {
      if (selectedMonth == 12) {
        selectedMonth = 1;
        selectedYear++;
      } else {
        selectedMonth++;
      }
      selectedDay = 1;
      dayController.jumpTo(0);
    }
    mainBloc.selectedDay = selectedDay;
    mainBloc.selectedMonth = selectedMonth;
    mainBloc.selectedYear = selectedYear;
    mainBloc.dayControllerPixels = dayController.position.pixels;
    updateFilter();

    emit(TasksInitialState(
      month: selectedMonth,
      day: selectedDay,
      filterTasks: filterTasks,
      mainFilterTasks: mainBloc.filterTasks,
    ));
  }

  void pressDayButton(DayButtonEvent event, Emitter<TasksState> emit) async {
    await updateNotCompleted();
    selectedDay = event.selectedDay;
    mainBloc.selectedDay = selectedDay;
    updateFilter();
    emit(TasksInitialState(
      month: selectedMonth,
      day: selectedDay,
      filterTasks: filterTasks,
      mainFilterTasks: mainBloc.filterTasks,
    ));
  }

  void updateFilter() {
    mainBloc.filterTasks = [];
    DateTime selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
    for (var task in mainBloc.tasks) {
      if ((task.endDate!.isAfter(selectedDate) || task.endDate!.isAtSameMomentAs(selectedDate)) &&
          (task.createdTime!.isBefore(selectedDate) || task.createdTime!.isAtSameMomentAs(selectedDate))) {
        mainBloc.filterTasks.add(task);
      }
    }
  }

  void listenDayButtonsController(ListenEvent event, Emitter<TasksState> emit) async {
    if (dayController.position.pixels >= 0) {
      dayControllerLeftDone = true;
    }
    if (dayController.position.pixels <= monthDays[selectedMonth - 1] * 62) {
      dayControllerRightDone = true;
    }

    if (dayController.position.pixels < -110 && dayControllerLeftDone) {
      dayControllerLeftDone = false;
      if (selectedMonth == 1) {
        selectedMonth = 12;
        selectedYear--;
      } else {
        selectedMonth--;
      }
      selectedDay = monthDays[selectedMonth - 1] == 28 && selectedYear == 2024 ? 29 : monthDays[selectedMonth - 1];
      emit(TasksInitialState(
        month: selectedMonth,
        day: selectedDay,
        filterTasks: filterTasks,
        mainFilterTasks: mainBloc.filterTasks,
      ));
      dayController.jumpTo((selectedDay) * 62 + 109 - event.width);
    }

    if (dayControllerRightDone &&
        dayController.position.pixels >
            ((monthDays[selectedMonth - 1] == 28 && selectedYear == 2024)
                ? 29 * 62 + 110 - event.width
                : monthDays[selectedMonth - 1] * 62 + 110 - event.width)) {
      dayControllerRightDone = false;
      if (selectedMonth == 12) {
        selectedMonth = 1;
        selectedYear++;
      } else {
        selectedMonth++;
      }
      selectedDay = 1;

      emit(TasksInitialState(
        month: selectedMonth,
        day: selectedDay,
        filterTasks: filterTasks,
        mainFilterTasks: mainBloc.filterTasks,
      ));
      dayController.jumpTo(-109);
    }
    mainBloc.selectedDay = selectedDay;
    mainBloc.selectedMonth = selectedMonth;
    mainBloc.selectedYear = selectedYear;
    mainBloc.dayControllerPixels = dayController.position.pixels;
    updateFilter();
  }

  void onReorder(OnReorderEvent event, Emitter<TasksState> emit) {
    final newIdx = event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex;
    if (filterEnabled) {
      final item = filterTasks.removeAt(event.oldIndex);
      filterTasks.insert(newIdx, item);
    } else {
      final item = mainBloc.filterTasks.removeAt(event.oldIndex);
      mainBloc.filterTasks.insert(newIdx, item);
    }

    emit(TasksInitialState(
      month: selectedMonth,
      day: selectedDay,
      filterTasks: filterTasks,
      mainFilterTasks: mainBloc.filterTasks,
    ));
  }

  void pushSinglePage(SinglePageEvent event, Emitter<TasksState> emit) async {
    TaskModel item = filterEnabled ? filterTasks[event.index] : mainBloc.filterTasks[event.index];
    TaskModel? model = await Navigator.push(
        event.context,
        MaterialPageRoute(
          builder: (context) => SinglePage(
            taskModel: item,
            mainBloc: mainBloc,
          ),
        ));
    if (model != null && event.context.mounted) {
      if (filterEnabled) {
        add(ApplyFilterEvent(context: event.context));
      } else {
        emit(TasksLoadingState());
        add(DayButtonEvent(selectedDay: selectedDay));
        emit(TasksInitialState(
          month: selectedMonth,
          day: selectedDay,
          filterTasks: filterTasks,
          mainFilterTasks: mainBloc.filterTasks,
        ));
      }
    }
  }

  void pressCancelFilter(CancelFilterEvent event, Emitter<TasksState> emit) async {
    if (event.remove) {
      filterEnabled = false;
      statusInProcess = false;
      statusCompleted = false;
      statusNotCompleted = false;
      emit(TasksInitialState(
        month: selectedMonth,
        day: selectedDay,
        filterTasks: filterTasks,
        mainFilterTasks: mainBloc.filterTasks,
      ));
      int currentMonthDayMax = AppDateTime.monthDays[DateTime.now().month - 1] == 28 && DateTime.now().year == 2024
          ? 29
          : AppDateTime.monthDays[DateTime.now().month - 1];

      double position = currentMonthDayMax - selectedDay < event.width ~/ 62
          ? ((currentMonthDayMax - (event.width ~/ 62)).toDouble()) * 62 - event.width % 62
          : (selectedDay.toDouble() - 1) * 62;
      await Future.delayed(const Duration(milliseconds: 10));
      dayController.animateTo(position, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      statusInProcess = statusInProcessOld;
      statusCompleted = statusCompletedOld;
      statusNotCompleted = statusNotCompletedOld;
      emit(TasksInitialState(
        month: selectedMonth,
        day: selectedDay,
        filterTasks: filterTasks,
        mainFilterTasks: mainBloc.filterTasks,
      ));
    }
    mainBloc.add(MainLanguageEvent());
  }

  Future<void> pressApplyFilter(ApplyFilterEvent event, Emitter<TasksState> emit) async {
    await updateNotCompleted();
    if (statusNotCompleted || statusCompleted || statusInProcess) {
      statusInProcessOld = statusInProcess;
      statusNotCompletedOld = statusCompleted;
      statusNotCompletedOld = statusNotCompleted;
      filterEnabled = true;
      filterTasks = [];
      for (TaskModel model in mainBloc.tasks) {
        switch (model.status!) {
          case TaskStatus.completed:
            if (statusCompleted) filterTasks.add(model);
            break;
          case TaskStatus.inProcess:
            if (statusInProcess) filterTasks.add(model);
            break;
          case TaskStatus.notCompleted:
            if (statusNotCompleted) filterTasks.add(model);
            break;
        }
      }

      emit(TasksInitialState(
        month: selectedMonth,
        day: selectedDay,
        filterTasks: filterTasks,
        mainFilterTasks: mainBloc.filterTasks,
      ));
      mainBloc.add(MainLanguageEvent());
    } else {
      Utils.mySnackBar(txt: 'set_status'.tr(), context: event.context, errorState: true);
    }
  }

  void pressStatusFilter(StatusFilterEvent event, Emitter<TasksState> emit) {
    switch (event.status) {
      case TaskStatus.completed:
        {
          statusCompleted = !statusCompleted;
          break;
        }
      case TaskStatus.notCompleted:
        {
          statusNotCompleted = !statusNotCompleted;
          break;
        }
      default:
        statusInProcess = !statusInProcess;
    }
    emit(TasksFilterState(
      completed: statusCompleted,
      inProcess: statusInProcess,
      notCompleted: statusNotCompleted,
    ));
  }

  void deleting(DeleteEvent event, Emitter<TasksState> emit) async {
    emit(TasksLoadingState());

    filterTasks.remove(event.model);
    mainBloc.filterTasks.remove(event.model);
    mainBloc.tasks.remove(event.model);
    await DBService.saveTasks(mainBloc.tasks);
    if (event.context.mounted) {
      Utils.mySnackBar(txt: 'deleting_complete'.tr(), context: event.context);
    }

    emit(TasksInitialState(month: selectedMonth, day: selectedDay, filterTasks: filterTasks, mainFilterTasks: mainBloc.filterTasks));
  }
}
