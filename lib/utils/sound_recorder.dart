import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class SoundRecorderManager {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  String? _currentFilePath;
  DateTime? _startTime;

  bool get isRecording => _recorder.isRecording;
  String? get filePath => _currentFilePath;

  /// Initialize recorder & request permission
  Future<void> init() async {
    if (_isInitialized) return;

    // Request microphone permission
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      throw RecordingPermissionException("Microphone permission not granted");
    }

    await _recorder.openRecorder();
    _isInitialized = true;
  }

  /// Start recording audio
  Future<void> start() async {
    if (!_isInitialized) {
      await init();
    }

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac";

    _currentFilePath = path;
    _startTime = DateTime.now();

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );
  }

  /// Stop recording and return File + duration (in seconds)
  Future<RecordingResult?> stop() async {
    if (!_isInitialized || !isRecording) {
      return null;
    }

    final recordedPath = await _recorder.stopRecorder();

    if (recordedPath == null) return null;

    final duration = DateTime.now().difference(_startTime!).inMilliseconds / 1000;

    return RecordingResult(
      file: File(recordedPath),
      duration: duration,
    );
  }

  /// Cancel recording (delete temporary file)
  Future<void> cancel() async {
    if (!_isInitialized || !isRecording) return;

    await _recorder.stopRecorder();

    if (_currentFilePath != null) {
      final file = File(_currentFilePath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    _currentFilePath = null;
    _startTime = null;
  }

  void dispose() {
    if (_isInitialized) {
      _recorder.closeRecorder();
      _isInitialized = false;
    }
  }
}

/// Custom result for recording
class RecordingResult {
  final File file;
  final double duration;

  RecordingResult({
    required this.file,
    required this.duration,
  });
}