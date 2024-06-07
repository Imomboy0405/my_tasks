part of 'new_bloc.dart';

abstract class NewState extends Equatable {}

class NewInitialState extends NewState {
  @override
  List<Object> get props => [];
}

class NewTaskLoadingState extends NewState {
  @override
  List<Object> get props => [];
}

class NewTaskState extends NewState {
  final bool suffixTitle;
  final bool borderTitle;
  final bool suffixContent;
  final bool borderContent;
  final DateTime selectedDate;
  final DateTime selectedDateTo;
  final int day;
  final int hour;
  final int minute;

  NewTaskState({
    required this.suffixTitle,
    required this.borderTitle,
    required this.suffixContent,
    required this.borderContent,
    required this.selectedDate,
    required this.selectedDateTo,
    required this.day,
    required this.hour,
    required this.minute,
  });

  @override
  List<Object> get props => [
    suffixTitle,
    borderTitle,
    suffixContent,
    borderContent,
    selectedDate,
    selectedDateTo,
    day,
    hour,
    minute,
  ];
}
