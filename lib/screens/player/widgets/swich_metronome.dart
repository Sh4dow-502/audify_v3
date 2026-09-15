// import 'package:animated_toggle_switch/animated_toggle_switch.dart';
// import 'package:audify/providers/audio_provider.dart';
// import 'package:audify/theme/custom_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SwichMetronome extends StatefulWidget {
//   const SwichMetronome({super.key});

//   @override
//   State<SwichMetronome> createState() => _SwichMetronomeState();
// }

// class _SwichMetronomeState extends State<SwichMetronome> {
//   bool _metronomeActive = true;
//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final audioProvider = context.read<AudioProvider>();
//     final metronomeActive = context.select<AudioProvider, bool>(
//       (p) => p.metronomeActive,
//     );
//     return AnimatedToggleSwitch<bool>.rolling(
//       current: metronomeActive,
//       values: [false, true],
//       height: 33,
//       indicatorSize: Size.fromWidth(28),
//       animationCurve: Curves.easeInQuad,
//       animationDuration: Duration(milliseconds: 150),
//       loadingAnimationCurve: Curves.linear,
//       indicatorAnimationType: AnimationType.none,
//       inactiveOpacityDuration: Duration(milliseconds: 0),
//       inactiveOpacityCurve: Curves.easeInQuad,
//       styleBuilder: (value) {
//         if (value) {
//           return ToggleStyle(
//             backgroundGradient: LinearGradient(
//               colors: [CustomColors.lightPink, CustomColors.lavanda],
//             ),
//             indicatorColor: colors.secondaryContainer,
//             borderColor: Colors.transparent,
//           );
//         } else {
//           return ToggleStyle(
//             backgroundColor: colors.tertiaryContainer,
//             indicatorColor: Colors.grey,
//             borderColor: Colors.grey,
//           );
//         }
//       },
//       onTap: (props) {
//         _metronomeActive = !_metronomeActive;
//         audioProvider.toggleMetronomeActive(_metronomeActive);
//         setState(() {});
//       },
//     );
//   }
// }
