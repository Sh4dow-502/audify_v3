import 'package:audify_v3/components/track_control/track_control.dart';
import 'package:audify_v3/models/song_entity.dart';
// import 'package:audify_v3/providers/controls_provider.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

// import 'package:provider/provider.dart';

class MetronomeControl extends StatelessWidget {
  final SongEntity song;
  const MetronomeControl({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final textStyles = context.theme.typography.body;
    // final showMetronome = context.watch<ControlsProvider>().showMetronome;
    //
    // if (!showMetronome) {
    //   return const SizedBox.shrink();
    // }
    // return FCard(
    //   child: Padding(
    //     padding: .all(10),
    //     child: Column(
    //       children: [
    //         Row(
    //           children: [
    //             Text("Metrónomo", style: textStyles.xs),
    //             const SizedBox(width: 10),
    //             const Text("|"),
    //             const SizedBox(width: 10),
    //             Text(
    //               "${song.metronome} BPM",
    //               style: textStyles.xs.copyWith(fontWeight: .bold),
    //             ),
    //             // const Spacer(),
    //             // FSwitch(
    //             //   value: activeMetronome,
    //             //   onChange: (value) {
    //             //     context.read<ControlsProvider>().switchActiveMetronome();
    //             //     context.read<TracksProvider>().toggleMuteTrack('metronome');
    //             //   },
    //             // ),
    //           ],
    //         ),
    //         TrackControl(trackName: "metronome"),
    //       ],
    //     ),
    //   ),
    // );
    //
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: FBorderRadius().lg,
          border: .all(color: context.theme.colors.border),
          color: context.theme.colors.background,
        ),
        padding: .all(15),
        child: Column(
          mainAxisSize: .min,
          children: [
            const SizedBox(height: 10),
            Row(
              spacing: 5,
              mainAxisAlignment: .center,
              children: [
                Text("Metrónomo", style: textStyles.sm),
                Text("•"),
                Text(
                  "${song.metronome} BPM",
                  style: textStyles.sm.copyWith(fontWeight: .bold),
                ),
              ],
            ),

            TrackControl(trackName: 'metronome'),
          ],
        ),
      ),
    );
  }
}
