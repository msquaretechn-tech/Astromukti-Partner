part of 'notification_bloc.dart';

@immutable
abstract class NotificationEvent {}

class NotificationIncreaseEvent extends NotificationEvent {
  final Map<String, dynamic> mData;

  NotificationIncreaseEvent({required this.mData});
}

class NotificationDecreaseEvent extends NotificationEvent {
  final String userId;
  NotificationDecreaseEvent(this.userId);
}

class NotificationResetEvent extends NotificationEvent {
  final String userId;
  NotificationResetEvent(this.userId);
}
