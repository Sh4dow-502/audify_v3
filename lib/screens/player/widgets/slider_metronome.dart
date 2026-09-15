// import 'package:audify_v3/providers/audio_provider.dart';
// import 'package:audify_v3/screens/media_screen/widgets/custom_gradient_slider.dart';
// import 'package:audify_v3/screens/player/widgets/custom_gradient_slider.dart';
// import 'package:audify_v3/theme/custom_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SliderMetronome extends StatefulWidget {
//   const SliderMetronome({super.key});

//   @override
//   State<SliderMetronome> createState() => _SliderMetronomeState();
// }

// class _SliderMetronomeState extends State<SliderMetronome> {
//   bool isPlaying = false;
//   double volume = 1;
//   double cacheVolume = 1;
//   double sliderValue = 1;

//   @override
//   Widget build(BuildContext context) {
//     // final colors = Theme.of(context).colorScheme;
//     final activeMetronome = context.select<AudioProvider, bool>(
//       (p) => p.metronomeActive,
//     );
//     final audioProvider = context.read<AudioProvider>();

//     return CustomGradientSlider(
//       gradientColors: [CustomColors.lightPink, CustomColors.lavanda],
//       dotColor: CustomColors.lightPink,
//       value: sliderValue,
//       varCond: volume,
//       label: "${(sliderValue * 100).toInt()}%",
//       divisions: 100,
//       onChanged: activeMetronome
//           ? (value) {
//               sliderValue = value;
//               volume = value;
//               cacheVolume = value;
//               audioProvider.setMetronomeVolume(value);
//               // _setVolume(value);
//               setState(() {});
//             }
//           : null,
//     );
//   }
// }
