import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'chat_timer_event.dart';
part 'chat_timer_state.dart';

class ChatTimerBloc extends Bloc<ChatTimerEvent, ChatTimerState> {
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  String elapsedTime = '00:00';

  ChatTimerBloc() : super(ChatTimerInitial()) {
    on<ChatStartEvent>(startTimer);
    on<ChatEndEvent>(stopTimer);
    on<ChatResetEvent>(resetTimer);
  }

  void startTimer(ChatStartEvent event, Emitter<ChatTimerState> emit) {
    stopwatch.start();

    timer = Timer.periodic(const Duration(milliseconds: 100), updateTime);
  }

  void updateTime(Timer t) {
    // Update elapsedTime directly without setState
    elapsedTime = formatDuration(stopwatch.elapsed);
    // log("elapsedTime : $elapsedTime");

    emit(ChatStartState(time: elapsedTime));
  }

  void stopTimer(ChatEndEvent event, Emitter<ChatTimerState> emit) {
    String hours = (stopwatch.elapsed.inHours % 60).toString().padLeft(2, '0');
    String minutes = (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    log("hours : $hours ");
    log("minutes : $seconds ");
    log("seconds : $seconds ");
    // int totalMinutes = stopwatch.elapsed.inHours * 60 + stopwatch.elapsed.inMinutes + stopwatch.elapsed.inSeconds ~/ 60;
    int totalMinutes = stopwatch.elapsed.inHours * 60 + stopwatch.elapsed.inMinutes + (stopwatch.elapsed.inSeconds >= 30 ? 1 : 0);

    emit(ChatEndState(time: double.parse(totalMinutes.toString()), userId:event.userId));
    stopwatch.stop();
    stopwatch.reset();
    elapsedTime = '00:00';
    timer?.cancel();
  }

  void resetTimer(ChatResetEvent event, Emitter<ChatTimerState> emit) {
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
