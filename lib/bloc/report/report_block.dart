import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../model/report_model.dart';
import '../../repository/repository.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  Repository homeRepository = Repository();

  ReportBloc() : super(ReportInitialState()) {
    on<ReportGetEvent>(getReportData);
  }

  Future<void> getReportData(
      ReportGetEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoadingState(isLoading: true));
    try {
      List<ReportModel> report = await homeRepository.getReport();

      emit(ReportGetState(report: report));
    } catch (e) {
      print("Error: $e");
      emit(ReportErrorState(error: e.toString()));
    }
  }
}

// EVENTS
@immutable
abstract class ReportEvent {}

class ReportGetEvent extends ReportEvent {}

// STATES
@immutable
abstract class ReportState {}

class ReportInitialState extends ReportState {}

class ReportLoadingState extends ReportState {
  final bool isLoading;
  ReportLoadingState({required this.isLoading});
}

class ReportErrorState extends ReportState {
  final String error;
  ReportErrorState({required this.error});
}

class ReportGetState extends ReportState {
  final List<ReportModel> report;
  ReportGetState({required this.report});
}
