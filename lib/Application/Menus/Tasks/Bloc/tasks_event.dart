part of 'tasks_bloc.dart';

abstract class TasksEvent extends Equatable {}

class DayButtonEvent extends TasksEvent {
  final int selectedDay;

  DayButtonEvent({required this.selectedDay});

  @override
  List<Object?> get props => [selectedDay];

}

class MonthButtonEvent extends TasksEvent {
  final bool left;
  final double width;

  MonthButtonEvent({this.left = false, this.width = 1});

  @override
  List<Object?> get props => [left, width];
}

class FilterEvent extends TasksEvent {
  @override
  List<Object?> get props => [];
}

class ListenEvent extends TasksEvent {
  final double width;

  ListenEvent({required this.width});

  @override
  List<Object?> get props => [width];
}

class InitialDayControllerEvent extends TasksEvent {
  final double width;

  InitialDayControllerEvent({required this.width});

  @override
  List<Object?> get props => [width];
}

class RefreshEvent extends TasksEvent {
  final BuildContext context;

  RefreshEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class OnReorderEvent extends TasksEvent {
  final int newIndex;
  final int oldIndex;

  OnReorderEvent({required this.newIndex, required this.oldIndex});

  @override
  List<Object?> get props => [newIndex, oldIndex];

}

class SinglePageEvent extends TasksEvent {
  final int index;
  final BuildContext context;
  final bool search;

  SinglePageEvent({required this.index, required this.context, this.search = false});

  @override
  List<Object?> get props => [index, context, search];
}

class CancelFilterEvent extends TasksEvent {
  final bool remove;
  final double width;

  CancelFilterEvent({this.remove = false, this.width = 0});

  @override
  List<Object?> get props => [remove, width];
}

class ApplyFilterEvent extends TasksEvent {
  final BuildContext context;

  ApplyFilterEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class StatusFilterEvent extends TasksEvent {
  final TaskStatus status;

  StatusFilterEvent({
    required this.status,
});

  @override
  List<Object?> get props => [status];

}

class DeleteEvent extends TasksEvent {
  final TaskModel model;
  final BuildContext context;

  DeleteEvent({required this.model, required this.context});

  @override
  List<Object?> get props => [model, context];
}