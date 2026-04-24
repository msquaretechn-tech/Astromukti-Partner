import 'dart:async';
import 'dart:developer';


import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../repository/repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {

  var authRepository =  Repository();

  ChatBloc() : super(ChatInitial()) {
    on<GetChatEvent>(fetchChats);
  }

  // send otp
  Future<void> fetchChats(GetChatEvent event, Emitter<ChatState> emit) async {
    // emit(ChatLoadingState(isLoading: true));
    try {
      Map<String, dynamic> response =
      await authRepository.getTotalChats();
      log('Choota babbu : $response');
      // emit(GetChatsState(response: response));
    } catch (e) {
      log("Error while : $e");
      // emit(AuthErrorState(error: e.toString()));
    }
  }
}
