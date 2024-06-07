part of 'new_bloc.dart';

abstract class NewEvent extends Equatable {}

class TaskChange extends NewEvent {
  @override
  List<Object?> get props => [];
}

class TaskSubmitted extends NewEvent {
  final bool title;
  final BuildContext? context;

  TaskSubmitted({this.title = false, this.context});

  @override
  List<Object?> get props => [title, context];
}

class TaskSave extends NewEvent {
  final BuildContext context;

  TaskSave({required this.context});

  @override
  List<Object?> get props => [context];
}

class ShowDatePickerEvent extends NewEvent {
  final BuildContext context;
  final bool toDate;

  ShowDatePickerEvent({required this.context, this.toDate = false});

  @override
  List<Object?> get props => [context, toDate];
}