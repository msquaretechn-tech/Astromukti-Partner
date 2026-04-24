
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';

class RingtonePlayer {
  static final RingtonePlayer _instance = RingtonePlayer._internal();
  factory RingtonePlayer() => _instance;
  RingtonePlayer._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isRinging = false;

  Future<void> playRingtone() async {
    if (isRinging) return;

    try {
      isRinging = true;

      // Play audio from assets
      await _audioPlayer.play(AssetSource('sounds/ringtone.mp3'));

      log('Ringtone started');

      // Auto stop after 1 second
      Future.delayed(const Duration(seconds: 5), () async {
        await stopRingtone();
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        isRinging = false;
      });
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
