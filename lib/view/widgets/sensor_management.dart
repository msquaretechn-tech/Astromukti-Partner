import 'dart:async';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/cupertino.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class SensorManagement {
  bool _isNear = false;
  StreamSubscription<dynamic>? streamSubscription;

  Future<void> startListening() async {
    try {
      await ProximitySensor.setProximityScreenOff(true);
      streamSubscription = ProximitySensor.events.listen((int event) {
        if (foundation.kDebugMode) {
          debugPrint("sensor event = $event");
        }
        _isNear = event > 0;
      });
    } catch (e) {
      debugPrint("Failed to start proximity sensor: $e");
    }
  }

  void stopListening() {
    streamSubscription?.cancel();
    streamSubscription = null;
  }

  bool get isNear => _isNear;
}
