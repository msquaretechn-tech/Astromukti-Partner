import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';

class ChatRingTone {
  static final ChatRingTone _instance = ChatRingTone._internal();
  factory ChatRingTone() => _instance;
  ChatRingTone._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isRinging = false;

  Future<void> playRingtone() async {
    if (isRinging) return;

    try {
      isRinging = true;

      // Play audio from assets in loop
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/ringtone.mp3'));

      log('Ringtone started in loop');

      // No auto stop, will stop when stopRingtone is called
    } catch (e) {
      log('Error playing ringtone: $e');
      isRinging = false;
    }
  }

  Future<void> stopRingtone() async {
    try {
      if (isRinging) {
        await _audioPlayer.stop();
        log('Ringtone stopped');
      }
      isRinging = false;
    } catch (e) {
      log('Error stopping ringtone: $e');
    }
  }
}
