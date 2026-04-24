part of 'call_timer_bloc.dart';

@immutable
abstract class CallTimerState {}

class CallTimerInitial extends CallTimerState {}

class CallStartState extends CallTimerState {
  final String time;

  CallStartState({required this.time});
}

class CallEndState extends CallTimerState {
  final double time;

  CallEndState({required this.time});
}

class CallResetState extends CallTimerState {}
