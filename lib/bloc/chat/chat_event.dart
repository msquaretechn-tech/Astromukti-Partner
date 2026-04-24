part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class ChatInitialEvent extends ChatEvent {}

class GetChatEvent extends ChatEvent {}

