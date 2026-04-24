abstract class ChatTimerStates {}

class TimerInitials extends ChatTimerStates {}

class TimerRunnings extends ChatTimerStates {
  final int remainingSeconds;

  TimerRunnings(this.remainingSeconds);
}

class TimerEnded extends ChatTimerStates {}
