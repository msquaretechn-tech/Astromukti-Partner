part of 'chat_timer_bloc.dart';

@immutable
abstract class ChatTimerState {}

class ChatTimerInitial extends ChatTimerState {}

class ChatStartState extends ChatTimerState {
  final String time;

  ChatStartState({required this.time});
}

class ChatEndState extends ChatTimerState {
  final double time;
  final String userId;

  ChatEndState({required this.time, required this.userId});
}

class ChatResetState extends ChatTimerState {}
