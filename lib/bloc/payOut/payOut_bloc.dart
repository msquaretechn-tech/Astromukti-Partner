import 'package:astro_mukti/bloc/payOut/payOut_event.dart';
import 'package:astro_mukti/bloc/payOut/payOut_stats.dart';
import 'package:astro_mukti/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PayoutBloc extends Bloc<PayOutEvent, PayoutStats> {
  final Repository _repository = Repository();

  PayoutBloc() : super(SetPayOutInitialState()) {
    on<PayOutGetEvent>(_getPayOutData);
  }

  Future<void> _getPayOutData(
    PayOutGetEvent event,
    Emitter<PayoutStats> emit,
  ) async {
    emit(PayOutLoadingStats(isLoading: true));

    try {
      final payOut = await _repository.getPayOut();
      emit(PayoutGetStats(stats: payOut));
    } catch (e) {
      emit(PayOutError(error: e.toString()));
    }
  }
}
