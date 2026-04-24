import 'dart:async';
import 'dart:developer';


import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../model/vender_detail_model.dart';
import '../../repository/repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  Repository homeRepository = Repository();

  DashboardBloc() : super(DashboardInitial()) {
    on<ChangeSwitchEvent>(changeSwitch);
    on<GetDashboardDataEvent>(getDashboardData);
  }

  //Switch Block
  Future<void> changeSwitch(ChangeSwitchEvent event, Emitter<DashboardState> emit) async {
    emit(ChangeSwitchState(isSwitch: event.switchValue, type: event.type));
  }

  // Get Dashboard Data
  Future<void> getDashboardData(GetDashboardDataEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoadingState(isLoading: true));
    try {
      VendorDetailsModel vendorDetail = await homeRepository.getVendorDetail();
      emit(DashboardGetDataState(vendorDetail: vendorDetail));
    } catch (e) {
      log("Error: $e");
      emit(DashboardErrorState(error: e.toString()));
    }
  }
}
