part of 'dashboard_bloc.dart';

@immutable
abstract class DashboardEvent {}

// Change switch event
class ChangeSwitchEvent extends DashboardEvent {
  final bool switchValue;
  final String type;

  ChangeSwitchEvent({required this.switchValue, required this.type});
}

//Get Banner Event
class GetDashboardDataEvent extends DashboardEvent {}
