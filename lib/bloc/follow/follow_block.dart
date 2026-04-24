import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../model/follow_model.dart';
import '../../repository/repository.dart';

// BLOC class
class FollowBloc extends Bloc<FollowEvent, FollowState> {
  Repository homeRepository = Repository();

  FollowBloc() : super(FollowInitialState()) {
    on<FollowGetEvent>(getFollowData);
  }

  Future<void> getFollowData(
      FollowGetEvent event, Emitter<FollowState> emit) async {
    emit(FollowLoadingState(isLoading: true));
    try {
      List<FollowModel> follow = await homeRepository.getUserFollowList();
      emit(FollowGetState(follow: follow));
    } catch (e) {
      print("Error: $e");
      emit(FollowErrorState(error: e.toString()));
    }
  }
}

// EVENTS
@immutable
abstract class FollowEvent {}

class FollowGetEvent extends FollowEvent {}

// STATES
@immutable
abstract class FollowState {}

class FollowInitialState extends FollowState {}

class FollowLoadingState extends FollowState {
  final bool isLoading;
  FollowLoadingState({required this.isLoading});
}

class FollowErrorState extends FollowState {
  final String error;
  FollowErrorState({required this.error});
}

class FollowGetState extends FollowState {
  final List<FollowModel> follow;
  FollowGetState({required this.follow});
}
