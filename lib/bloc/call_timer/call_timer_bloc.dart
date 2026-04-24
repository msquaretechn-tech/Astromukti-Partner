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

  CallTimerBloc() : super(CallTimerInitial()) {
    on<CallStartEvent>(startTimer);
    on<CallEndEvent>(stopTimer);
    on<CallResetEvent>(resetTimer);
  }

  void startTimer(CallStartEvent event, Emitter<CallTimerState> emit) {
    stopwatch.start();

    timer = Timer.periodic(const Duration(milliseconds: 100), updateTime);
  }

  void updateTime(Timer t) {
    // Update elapsedTime directly without setState
    elapsedTime = formatDuration(stopwatch.elapsed);
   // print("elapsedTime : $elapsedTime");

    emit(CallStartState(time: elapsedTime));
  }

  void stopTimer(CallEndEvent event, Emitter<CallTimerState> emit) {
    String hours = (stopwatch.elapsed.inHours % 60).toString().padLeft(2, '0');
    String minutes = (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    print("hours : $hours ");
    print("minutes : $seconds ");
    print("seconds : $seconds ");
    // int totalMinutes = stopwatch.elapsed.inHours * 60 + stopwatch.elapsed.inMinutes + stopwatch.elapsed.inSeconds ~/ 60;
    // int totalMinutes = stopwatch.elapsed.inHours * 60 + stopwatch.elapsed.inMinutes + (stopwatch.elapsed.inSeconds >= 30 ? 1 : 0);
    int totalMinutes = stopwatch.elapsed.inHours * 60 + stopwatch.elapsed.inMinutes + (stopwatch.elapsed.inSeconds > 0 && stopwatch.elapsed.inSeconds < 59 ? 1 : 0);


    emit(CallEndState(time: double.parse(totalMinutes.toString())));
    stopwatch.stop();
    stopwatch.reset();
    elapsedTime = '00:00';
    timer?.cancel();
  }

  void resetTimer(CallResetEvent event, Emitter<CallTimerState> emit) {
    stopwatch.reset();

    elapsedTime = '00:00';
  }

  String formatDuration(Duration elapsed) {
    String minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    String milliseconds = (elapsed.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds';
  }
}
