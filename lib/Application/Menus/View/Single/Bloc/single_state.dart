part of 'single_bloc.dart';

abstract class SingleState extends Equatable {
  const SingleState();
}

class SingleInitialState extends SingleState {
  final bool completed;
  final TaskModel taskModel;

  const SingleInitialState({
    required this.completed,
    required this.taskModel,
  });

  @override
  List<Object> get props => [completed, taskModel];
}

class SingleLoadingState extends SingleState {
  @override
  List<Object> get props => [];
}

class SingleDeleteState extends SingleState {
  @override
  List<Object> get props => [];
}
