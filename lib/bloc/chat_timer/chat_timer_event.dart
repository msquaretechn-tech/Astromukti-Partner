part of 'chat_timer_bloc.dart';

@immutable
abstract class ChatTimerEvent {}

class ChatInitialEvent extends ChatTimerEvent {}

class ChatStartEvent extends ChatTimerEvent {}

class ChatEndEvent extends ChatTimerEvent {
  final String userId;

  ChatEndEvent({required this.userId});
}

class ChatResetEvent extends ChatTimerEvent {}
