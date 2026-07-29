

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// ChatRingTone — plays/stops ringtone using:
/// PRIMARY:  sendBroadcast() via android_intent_plus
///           → RingtoneBroadcastReceiver → RingtoneService (native MediaPlayer)
///           Works from background Dart isolate
///
/// FALLBACK: MethodChannel (main engine / foreground only)
///           → RingtoneService via direct Intent from MainActivity
///
/// Both paths use RingtoneService which has android:stopWithTask="true"
/// → auto-stops on force-kill, no orphan ringtone
class ChatRingTone {
  static final ChatRingTone _instance = ChatRingTone._internal();
  factory ChatRingTone() => _instance;
  ChatRingTone._internal();


  static const _channel = MethodChannel('com.astro.hanumanta/ringtone');

  // Broadcast action strings (must match RingtoneBroadcastReceiver)
  static const _actionPlay = 'com.jyotishastro.PLAY_RINGTONE';
  static const _actionStop = 'com.jyotishastro.STOP_RINGTONE';
  static const _package = 'com.jyotishastro';

  bool isRinging = false;

  Future<void> playRingtone() async {
    if (isRinging) return;
    await _sendBroadcast(_actionPlay);
    isRinging = true;
  }

  /// Force play — resets stuck flag. Use in background isolate.
  Future<void> playRingtoneForce() async {
    isRinging = false;
    await playRingtone();
  }

  Future<void> stopRingtone() async {
    try {
      await _sendBroadcast(_actionStop);
    } catch (_) {}
    isRinging = false;
  }

  /// Sends a broadcast to RingtoneBroadcastReceiver.
  /// android_intent_plus.sendBroadcast() works from background Dart isolate.
  Future<void> _sendBroadcast(String action) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      // PRIMARY: sendBroadcast — available in background isolate
      final intent = AndroidIntent(
        action: action,
        package: _package,
        componentName: 'com.jyotishastro.RingtoneBroadcastReceiver',
      );
      await intent.sendBroadcast();
      print('ChatRingTone: broadcast sent [$action]');
    } catch (e) {
      print('ChatRingTone: sendBroadcast failed ($e), trying MethodChannel fallback...');
      // FALLBACK: MethodChannel — foreground / main engine only
      try {
        if (action == _actionPlay) {
          await _channel.invokeMethod('playRingtone');
        } else {
          await _channel.invokeMethod('stopRingtone');
        }
        print('ChatRingTone: MethodChannel fallback success [$action]');
      } catch (e2) {
        print('ChatRingTone: Both methods failed: $e2');
        if (action == _actionPlay) isRinging = false;
      }
    }
  }
}
