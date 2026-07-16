import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'call_timer_event.dart';
part 'call_timer_state.dart';

class CallTimerBloc extends Bloc<CallTimerEvent, CallTimerState> {
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  String elapsedTime = '00:00';
  int? remainingSeconds;

  CallTimerBloc() : super(CallTimerInitial()) {
    on<CallStartEvent>(startTimer);
    on<CallEndEvent>(stopTimer);
    on<CallResetEvent>(resetTimer);
  }

  void startTimer(CallStartEvent event, Emitter<CallTimerState> emit) {
    if (event.totalSeconds != null) {
      remainingSeconds = event.totalSeconds;
    }
    stopwatch.start();

    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), updateTime);
  }

  void updateTime(Timer t) {
    elapsedTime = formatDuration(stopwatch.elapsed);

    String? remainingStr;
    if (remainingSeconds != null) {
      // Calculate remaining based on elapsed seconds
      int currentRemaining = remainingSeconds! - stopwatch.elapsed.inSeconds;
      if (currentRemaining <= 0) {
        currentRemaining = 0;
        add(CallEndEvent());
      }
      remainingStr = _formatSeconds(currentRemaining);
    }

    emit(CallStartState(time: elapsedTime, remainingTime: remainingStr));
  }

  String _formatSeconds(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void stopTimer(CallEndEvent event, Emitter<CallTimerState> emit) {
    int totalMinutes = stopwatch.elapsed.inHours * 60 +
        stopwatch.elapsed.inMinutes +
        (stopwatch.elapsed.inSeconds > 0 && stopwatch.elapsed.inSeconds < 59 ? 1 : 0);

    emit(CallEndState(time: double.parse(totalMinutes.toString())));
    stopwatch.stop();
    stopwatch.reset();
    elapsedTime = '00:00';
    remainingSeconds = null;
    timer?.cancel();
  }

  void resetTimer(CallResetEvent event, Emitter<CallTimerState> emit) {
    stopwatch.reset();
    elapsedTime = '00:00';
    remainingSeconds = null;
    timer?.cancel();
    emit(CallTimerInitial());
  }

  String formatDuration(Duration elapsed) {
    String minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
