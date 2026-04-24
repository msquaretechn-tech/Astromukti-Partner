
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/my_earning_model.dart';
import '../../repository/repository.dart';

class EarningBloc extends Bloc<EarningEvent, EarningState> {
  Repository homeRepository = Repository();

  EarningBloc() : super(EarningInitialState()) {
    on<EarningGetEvent>(getEarningData);
  }

  Future<void> getEarningData(
      EarningGetEvent event, Emitter<EarningState> emit) async {
    emit(EarningLoadingState(isLoading: true));
    try {
      List<MyEarningModel> earning =
          await homeRepository.monthPerformance("monthly");
      emit(EarningGetState(earning: earning));
    } catch (e) {
      print("Error: $e");
      emit(EarningErrorState(error: e.toString()));
    }
  }
}

// EVENTS
abstract class EarningEvent {}

class EarningGetEvent extends EarningEvent {}

// STATES
abstract class EarningState {}

class EarningInitialState extends EarningState {}

class EarningLoadingState extends EarningState {
  final bool isLoading;
  EarningLoadingState({required this.isLoading});
}

class EarningErrorState extends EarningState {
  final String error;
  EarningErrorState({required this.error});
}

class EarningGetState extends EarningState {
  final List<MyEarningModel> earning;
  EarningGetState({required this.earning});
}
