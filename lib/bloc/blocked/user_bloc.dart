import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../model/blocked_model.dart';
import '../../repository/repository.dart';

// BLOC class
class BlockedBloc extends Bloc<BlockedEvent, BlockedState> {
  Repository homeRepository = Repository();

  BlockedBloc() : super(BlockedInitialState()) {
    on<BlockedGetEvent>(getBlockedData);
  }

  Future<void> getBlockedData(
      BlockedGetEvent event, Emitter<BlockedState> emit) async {
    emit(BlockedLoadingState(isLoading: true));
    try {
      List<BlockedModel> blocked = await homeRepository.getBlockedUserList();
      emit(BlockedGetState(blocked: blocked));
    } catch (e) {
      print("Error: $e");
      emit(BlockedErrorState(error: e.toString()));
    }
  }
}

// EVENTS
@immutable
abstract class BlockedEvent {}

class BlockedGetEvent extends BlockedEvent {}

// STATES
@immutable
abstract class BlockedState {}

class BlockedInitialState extends BlockedState {}

class BlockedLoadingState extends BlockedState {
  final bool isLoading;
  BlockedLoadingState({required this.isLoading});
}

class BlockedErrorState extends BlockedState {
  final String error;
  BlockedErrorState({required this.error});
}

class BlockedGetState extends BlockedState {
  final List<BlockedModel> blocked;
  BlockedGetState({required this.blocked});
}
