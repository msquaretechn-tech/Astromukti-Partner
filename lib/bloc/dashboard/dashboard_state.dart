part of 'dashboard_bloc.dart';

@immutable
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoadingState extends DashboardState {
  final bool isLoading;

  DashboardLoadingState({required this.isLoading});
}

class DashboardErrorState extends DashboardState {
  final dynamic error;

  DashboardErrorState({required this.error});
}


class DashboardGetDataState extends DashboardState {
  final VendorDetailsModel vendorDetail;

  DashboardGetDataState({required this.vendorDetail,});
}

//Switch state
class ChangeSwitchState extends DashboardState {
  final bool isSwitch;
  final String type;

  ChangeSwitchState({required this.type, this.isSwitch = false});

  ChangeSwitchState copyWith({bool? isSwitch, required String type}) {
    return ChangeSwitchState(
      isSwitch: isSwitch ?? this.isSwitch,
      type: type,
    );
  }
}
