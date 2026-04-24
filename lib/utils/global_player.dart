

import 'package:astro_mukti/utils/voice_message.dart';

class GlobalAudioPlayer {
  static final GlobalAudioPlayer _instance = GlobalAudioPlayer._internal();
  factory GlobalAudioPlayer() => _instance;

  late AudioPlayerController controller;

  GlobalAudioPlayer._internal() {
    controller = AudioPlayerController();
  }
}
