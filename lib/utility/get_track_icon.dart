import 'package:flutter/material.dart';
import 'package:forui/assets.dart';

IconData getTrackIcon(String iconName) {
  switch (iconName) {
    case 'other':
      return FLucideIcons.audioLines;
    case 'vocals':
      return FLucideIcons.micVocal;
    case 'drums':
      return FLucideIcons.drum;
    case 'bass':
      return FLucideIcons.music3;
    case 'piano':
      return FLucideIcons.keyboardMusic;
    case 'guitar':
      return FLucideIcons.guitar;
    case 'metronome':
      return FLucideIcons.metronome;
    default:
      return FLucideIcons
          .audioWaveform; // Default icon if the name doesn't match
  }
}
