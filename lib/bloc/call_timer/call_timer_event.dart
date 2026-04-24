part of 'call_timer_bloc.dart';

@immutable
abstract class CallTimerEvent {}

class CallInitialEvent extends CallTimerEvent {}

class CallStartEvent extends CallTimerEvent {}

class CallEndEvent extends CallTimerEvent {}

class CallResetEvent extends CallTimerEvent {}
