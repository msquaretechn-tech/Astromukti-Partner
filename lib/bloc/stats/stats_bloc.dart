import 'package:bloc/bloc.dart';
import 'package:astro_mukti/bloc/stats/stats_event.dart';
import 'package:astro_mukti/bloc/stats/stats_state.dart';
import 'package:astro_mukti/model/stats_model.dart';
import 'package:astro_mukti/repository/repository.dart';

class StatsBloc extends Bloc<StateEvent, StatsState> {
  final Repository _repository = Repository();

  StatsBloc() : super(StatsInitialState()) {
    on<StateGetEvent>(_getStatsData);
  }

  Future<void> _getStatsData(
      StateGetEvent event,
      Emitter<StatsState> emit,
      ) async {
    emit(StatsLoadingState(isLoading: true));

    try {
      final stats = await _repository.getStats();
      emit(StatsGetState(stats: stats));
    } catch (e) {
      emit(StatsGetState(stats: StatsModel.empty()));
    }
  }
}
