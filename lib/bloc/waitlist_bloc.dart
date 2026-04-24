import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../repository/repository.dart';

/// BLOC CLASS
class WaitlistBloc extends Bloc<WaitlistEvent, WaitlistState> {
  final Repository _repository = Repository();

  WaitlistBloc() : super(WaitlistInitialState()) {
    on<WaitlistGetEvent>(getWaitlist);
    on<UserCallResponseEvent>(userCallResponse);
  }

  // Get Waitlist
  Future<void> getWaitlist(
      WaitlistGetEvent event, Emitter<WaitlistState> emit) async {
    Map<String, dynamic> waitlist = await _repository.getWaitingCall();

    log("waitlist : ${waitlist['data']}");
    emit(WaitlistGetSuccessState(waitlist: waitlist['data']));
  }

  // User Call Response
  Future<void> userCallResponse(
      UserCallResponseEvent event, Emitter<WaitlistState> emit) async {
    log("userCallResponse${event.isJoined}");
    emit(UserCallResponseState(
        userId: event.userId,
        streamType: event.streamType,
        isJoined: event.isJoined,
        latestUid: event.latestUid));
  }
}

/// EVENTS
@immutable
abstract class WaitlistEvent {}

class WaitlistGetEvent extends WaitlistEvent {}

class UserCallResponseEvent extends WaitlistEvent {
  final String userId;
  final String streamType;
  final String isJoined;
  final String latestUid;

  UserCallResponseEvent({
    required this.userId,
    required this.streamType,
    required this.isJoined,
    required this.latestUid,
  });
}

/// STATES
@immutable
abstract class WaitlistState {}

class WaitlistInitialState extends WaitlistState {}

class WaitlistLoadingState extends WaitlistState {}

class WaitlistErrorState extends WaitlistState {}

class WaitlistGetSuccessState extends WaitlistState {
  final List waitlist;

  WaitlistGetSuccessState({required this.waitlist});
}

class UserCallResponseState extends WaitlistState {
  final String userId;
  final String streamType;
  final String isJoined;
  final String latestUid;

  UserCallResponseState({
    required this.userId,
    required this.streamType,
    required this.isJoined,
    required this.latestUid,
  });
}
