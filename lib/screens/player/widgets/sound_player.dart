// import 'package:audify/screens/media_screen/utils/resolve_icon.dart';
// import 'package:audify/screens/media_screen/widgets/custom_gradient_slider.dart';
// import 'package:audify/theme/custom_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:just_audio/just_audio.dart';

// class SoundPlayer extends StatefulWidget {
//   const SoundPlayer({super.key, required this.player});
//   final AudioPlayer player;
//   @override
//   State<SoundPlayer> createState() => _SoundPlayerState();
// }

// class _SoundPlayerState extends State<SoundPlayer> {
//   bool isPlaying = false;
//   double volume = 1;
//   double cacheVolume = 1;
//   double sliderValue = 1;
//   bool enableTrack = true;

//   @override
//   void initState() {
//     super.initState();
//     // Inicializar sliderValue con el volumen actual del player
//     volume = widget.player.volume;
//     sliderValue = widget.player.volume;
//     cacheVolume = widget.player.volume;
//   }

//   @override
//   void dispose() {
//     // widget.player.seek(Duration.zero);
//     // widget.player.stop();
//     // widget.player.setVolume(1);
//     super.dispose();
//   }

//   void _setVolume(double value) {
//     widget.player.setVolume(value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final valueKey = widget.key as ValueKey;

//     return Container(
//       margin: EdgeInsets.only(bottom: 15),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 if (volume != 0) {
//                   _setVolume(0);
//                   volume = 0;
//                 } else if (volume == 0) {
//                   _setVolume(cacheVolume);
//                   volume = cacheVolume;
//                 }
//                 enableTrack = !enableTrack;

//                 if (enableTrack) {
//                   _setVolume(volume);
//                 }
//                 setState(() {});
//               },
//               child: SvgPicture.asset(
//                 ResolveIcon.resolveIcon((valueKey.value).toString()),
//                 height: 30,
//                 width: 30,
//                 colorFilter: ColorFilter.mode(
//                   enableTrack ? Colors.white : Colors.grey,
//                   BlendMode.srcIn,
//                 ),
//                 alignment: Alignment.center,
//               ),
//             ),
//             Expanded(
//               child: CustomGradientSlider(
//                 gradientColors: [
//                   CustomColors.lightPurple,
//                   // CustomColors.lightMorado,
//                   CustomColors.morado,
//                 ],
//                 dotColor: CustomColors.lightPurple,
//                 value: sliderValue,
//                 varCond: volume,
//                 label: "${(sliderValue * 100).round()}%",
//                 divisions: null,
//                 trackHeight: 2,
//                 onChanged: enableTrack
//                     ? (value) {
//                         sliderValue = value;

//                         volume = value;
//                         cacheVolume = value;
//                         if (enableTrack) {
//                           _setVolume(value);
//                         }
//                         setState(() {});
//                       }
//                     : null,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
