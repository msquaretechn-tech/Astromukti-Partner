abstract class RemainingTimerEvent {}

class StartTimerEvent extends RemainingTimerEvent {
  final double wallet;
  final double rate;

  StartTimerEvent({required this.wallet, required this.rate});
}

class TickEvent extends RemainingTimerEvent {}

class StopTimerEvent extends RemainingTimerEvent {}
