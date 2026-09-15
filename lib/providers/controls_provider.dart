import 'package:audify_v3/services/audio_service.dart';
import 'package:flutter/material.dart';

class ControlsProvider extends ChangeNotifier {
  final AudioService _audioService;
  ControlsProvider(this._audioService);
  bool showMetronome = false;
  bool activeMetronome = true;
  double globalSpeed = 1.0;
  List<double> speedOptions = [0.85, 1.0, 1.15];

  void switchActiveMetronome() {
    activeMetronome = !activeMetronome;
    notifyListeners();
  }

  void toggleMetronome() {
    showMetronome = !showMetronome;
    notifyListeners();
  }

  void setGlobalSpeed(double speed) {
    if (speed < 0.5) speed = 0.5;
    if (speed > 1.5) speed = 1.5;
    globalSpeed = speed;
    globalSpeed = double.parse(globalSpeed.toStringAsFixed(2));
    _audioService.setGlobalSpeed(speed);
    notifyListeners();
  }
}
