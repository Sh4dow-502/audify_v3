import 'dart:ui';

import 'package:audify_v3/theme/custom_colors.dart';

Color getTrackColor(String trackName) {
  switch (trackName) {
    case 'drums':
      return CustomColors.pinkDrum; // Red
    case 'bass':
      return CustomColors.celeste; // Green
    case 'guitar':
      return CustomColors.orangeGuitar; // Blue
    case 'vocals':
      return CustomColors.blueVocals; // Yellow
    case 'piano':
      return CustomColors.lightPurple; // Yellow
    case 'metronome':
      return CustomColors.cyanGreen; // Yellow
    default:
      return CustomColors.lightBlue; // Grey for unknown tracks
  }
}
