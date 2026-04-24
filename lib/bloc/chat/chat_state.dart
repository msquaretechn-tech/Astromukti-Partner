part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

// loading
class ChatLoadingState extends ChatEvent {
  final bool isLoading;

  ChatLoadingState({required this.isLoading});
}

// get chats
class GetChatsState extends ChatEvent {
  final dynamic response;

  GetChatsState({required this.response});
}
