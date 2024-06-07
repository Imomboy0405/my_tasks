part of 'tasks_bloc.dart';

abstract class TasksState extends Equatable {}

class TasksInitialState extends TasksState {
  final int day;
  final int month;
  final List<TaskModel> filterTasks;
  final List<TaskModel> mainFilterTasks;

  TasksInitialState({
    required this.month,
    required this.day,
    required this.filterTasks,
    required this.mainFilterTasks,
  });

  @override
  List<Object> get props => [day, month, filterTasks, mainFilterTasks];
}

class TasksLoadingState extends TasksState {
  @override
  List<Object> get props => [];
}

class TasksFilterState extends TasksState {
  final bool completed;
  final bool notCompleted;
  final bool inProcess;

  TasksFilterState({
    required this.completed,
    required this.notCompleted,
    required this.inProcess,
});

  @override
  List<Object> get props => [completed, notCompleted, inProcess];
}
