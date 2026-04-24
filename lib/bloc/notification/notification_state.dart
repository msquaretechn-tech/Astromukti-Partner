part of 'notification_bloc.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationUpdateState extends NotificationState {
  // final int counter;
  // final String userId;
  final Map<String, int> userCounters;
 // NotificationUpdateState(this.counter, this.userId);
  NotificationUpdateState(this.userCounters);
}
