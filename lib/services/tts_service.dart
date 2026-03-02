import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;

  Future<void> init() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _isPaused = false;
    });
    _tts.setCancelHandler(() {
      _isSpeaking = false;
      _isPaused = false;
    });
  }

  Future<void> speak(String text) async {
    if (_isSpeaking) await stop();
    _isSpeaking = true;
    _isPaused = false;
    await _tts.speak(text);
  }

  Future<void> pause() async {
    if (_isSpeaking) {
      await _tts.pause();
      _isPaused = true;
      _isSpeaking = false;
    }
  }

  Future<void> resume() async {
    if (_isPaused) {
      await _tts
          .speak(''); // flutter_tts no tiene resume nativo en todos los OS
      _isPaused = false;
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    _isPaused = false;
  }

  Future<void> speakStep(int stepNumber, String instruction) async {
    final text = 'Paso $stepNumber. $instruction';
    await speak(text);
  }

  void dispose() {
    _tts.stop();
  }
}
