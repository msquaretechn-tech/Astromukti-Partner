import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:astro_mukti/bloc/remaining_rimer_bloc/remaining_event.dart';
import 'package:astro_mukti/bloc/remaining_rimer_bloc/remaining_state.dart';


class ChatsTimerBloc extends Bloc<RemainingTimerEvent, ChatTimerStates> {
  Timer? _timer;
  int _remainingSeconds = 0;

  ChatsTimerBloc() : super(TimerInitials()) {
    on<StartTimerEvent>((event, emit) {
      _timer?.cancel();

      double wallet = event.wallet;
      double rate = event.rate <= 0 ? 1 : event.rate;

      double talkMinutes = wallet / rate;
      _remainingSeconds = (talkMinutes * 60).round();

      if (_remainingSeconds <= 0) {
        emit(TimerEnded());
        return;
      }

      emit(TimerRunnings(_remainingSeconds));

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          timer.cancel();
          emit(TimerEnded());
        } else {
          emit(TimerRunnings(_remainingSeconds));
        }
      });
    });

    on<StopTimerEvent>((event, emit) {
      _timer?.cancel();
      emit(TimerEnded());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
