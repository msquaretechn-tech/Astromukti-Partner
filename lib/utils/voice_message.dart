import 'package:just_audio/just_audio.dart';

class AudioPlayerController {
  final AudioPlayer _player = AudioPlayer();
  String? lastUrl;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;

  Future<void> play(String url) async {
    try {
      if (lastUrl != url) {
        lastUrl = url;
        await _player.setUrl(url);
      }

      await _player.play();

    } catch (e) {
      print("Play error: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
  }

  String? get currentUrl => lastUrl;

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> seek(Duration duration) async {
    await _player.seek(duration);
  }

  Duration? get duration => _player.duration;

  void dispose() {
    _player.dispose();
  }
}
