import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  // int counter = 0;
  final Map<String, int> _notificationCountMap = {};
  NotificationBloc() : super(NotificationInitial()) {
    on<NotificationIncreaseEvent>(onNotificationIncrease);
    on<NotificationDecreaseEvent>(onNotificationDecrease);
    on<NotificationResetEvent>(onNotificationReset);
    on<NotificationResetAllEvent>(onNotificationResetAll);
  }

  void onNotificationIncrease(
    NotificationIncreaseEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // counter = counter + 1;
    // log('Notification Data : ${event.mData}');
    // // log('Notification Data : ${(event.mData).runtimeType}');
    // log('Notification Data : ${event.mData['userId']}');
    final userId = event.mData['userId'] ?? '';
    if (userId.isEmpty) return;

    _notificationCountMap[userId] = (_notificationCountMap[userId] ?? 0) + 1;

    log('Increased: ${_notificationCountMap[userId]} for userId: $userId');
    //emit(NotificationUpdateState(counter, event.mData['userId']));
    emit(NotificationUpdateState(Map.from(_notificationCountMap)));
  }

  void onNotificationDecrease(
    NotificationDecreaseEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // counter = counter - 1;
    // emit(NotificationUpdateState(counter, ''));
    final userId = event.userId;
    if (userId.isEmpty || !_notificationCountMap.containsKey(userId)) return;

    _notificationCountMap[userId] = (_notificationCountMap[userId]! - 1)
        .clamp(0, double.infinity)
        .toInt();

    log('Decreased: ${_notificationCountMap[userId]} for userId: $userId');
    emit(NotificationUpdateState(Map.from(_notificationCountMap)));
  }

  void onNotificationReset(
    NotificationResetEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // counter = 0;
    // emit(NotificationUpdateState(counter, ''));

    final userId = event.userId;
    if (userId.isEmpty) return;

    _notificationCountMap[userId] = 0;
    _notificationCountMap.remove(userId);

    log('Reset: 0 for userId: $userId');
    emit(NotificationUpdateState(Map.from(_notificationCountMap)));
  }

  void onNotificationResetAll(
    NotificationResetAllEvent event,
    Emitter<NotificationState> emit,
  ) async {
    _notificationCountMap.clear();
    log('Reset all notifications');
    emit(NotificationUpdateState(Map.from(_notificationCountMap)));
  }
}
