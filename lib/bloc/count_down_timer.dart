import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

// BLOC
class CountDownTimerBloc extends Bloc<CountDownTimerEvent, CountDownTimerState> {
  static const int _tickDuration = 1;

  StreamSubscription<int>? _tickerSubscription;

  CountDownTimerBloc() : super(const CountDownTimerState(duration: 0)) {
    on<StartTimer>(_onStart);
    on<PauseTimer>(_onPause);
    on<ResumeTimer>(_onResume);
    on<ResetTimer>(_onReset);
    on<TickTimer>(_onTick);
    on<StopTimer>(_onStop);
  }

  // Event handler for StartTimer
  void _onStart(StartTimer event, Emitter<CountDownTimerState> emit) {
    emit(state.copyWith(isRunning: true, isCompleted: false, duration: event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _tick(event.duration).listen((duration) {
      add(TickTimer(duration));
    });
  }

  // Event handler for PauseTimer
  void _onPause(PauseTimer event, Emitter<CountDownTimerState> emit) {
    if (state.isRunning) {
      _tickerSubscription?.pause();
      emit(state.copyWith(isRunning: false));
    }
  }

  // Event handler for ResumeTimer
  void _onResume(ResumeTimer event, Emitter<CountDownTimerState> emit) {
    if (!state.isRunning) {
      _tickerSubscription?.resume();
      emit(state.copyWith(isRunning: true));
    }
  }

  // Event handler for ResetTimer
  void _onReset(ResetTimer event, Emitter<CountDownTimerState> emit) {
    _tickerSubscription?.cancel();
    emit(state.copyWith(duration: 0, isRunning: false, isCompleted: false));
  }

  // Event handler for StopTimer
  void _onStop(StopTimer event, Emitter<CountDownTimerState> emit) {
    _tickerSubscription?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  // Event handler for TickTimer
  void _onTick(TickTimer event, Emitter<CountDownTimerState> emit) {
    if (event.duration >= 0) {
      emit(state.copyWith(duration: event.duration));
    } else {
      _tickerSubscription?.cancel();
      emit(state.copyWith(isRunning: false, isCompleted: true));
    }
  }

  // Stream to generate ticks for countdown
  Stream<int> _tick(int startDuration) {
    return Stream.periodic(const Duration(seconds: _tickDuration), (x) => startDuration - x - 1)
        .take(startDuration + 1); // Automatically stops when duration is exhausted
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}

// EVENTS
abstract class CountDownTimerEvent extends Equatable {
  const CountDownTimerEvent();

  @override
  List<Object> get props => [];
}

class StartTimer extends CountDownTimerEvent {
  final int duration;

  const StartTimer(this.duration);

  @override
  List<Object> get props => [duration];
}

class PauseTimer extends CountDownTimerEvent {}

class ResumeTimer extends CountDownTimerEvent {}

class ResetTimer extends CountDownTimerEvent {}

class StopTimer extends CountDownTimerEvent {}

class TickTimer extends CountDownTimerEvent {
  final int duration;

  const TickTimer(this.duration);

  @override
  List<Object> get props => [duration];
}

// STATES
class CountDownTimerState extends Equatable {
  final int duration;
  final bool isRunning;
  final bool isCompleted;

  const CountDownTimerState({
    required this.duration,
    this.isRunning = false,
    this.isCompleted = false,
  });

  CountDownTimerState copyWith({
    int? duration,
    bool? isRunning,
    bool? isCompleted,
  }) {
    return CountDownTimerState(
      duration: duration ?? this.duration,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object> get props => [duration, isRunning, isCompleted];
}