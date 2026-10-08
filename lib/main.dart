import 'package:audify_v3/db/objectbox_handler.dart';
import 'package:audify_v3/providers/audio_provider.dart';
import 'package:audify_v3/providers/controls_provider.dart';
import 'package:audify_v3/providers/loading_provider.dart';
import 'package:audify_v3/providers/song_provider.dart';
import 'package:audify_v3/providers/structure_provider.dart';
import 'package:audify_v3/providers/tracks_provider.dart';
import 'package:audify_v3/screens/home/home_screen.dart';
import 'package:audify_v3/services/audio_service.dart';
import 'package:audify_v3/services/database_service.dart';
import 'package:audify_v3/services/loading_service.dart';
import 'package:audify_v3/services/song_service.dart';
import 'package:audify_v3/services/structure_service.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';

late ObjectBox objectBox;

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension DurationFormatting on Duration {
  String toTimeFormat() {
    String twoDigits(int n) => n.abs().toString().padLeft(2, '0');

    final hours = inHours;
    final minutes = inMinutes.remainder(60); // o inMinutes.remainder(60)
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // try {
  //   await SoLoud.instance.init();
  // } catch (e) {
  //   debugPrint("Error initializing SoLoud: $e");
  // }
  objectBox = await ObjectBox.create();

  final audioService = AudioService();
  await audioService.init();

  // await initObjectBox();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => SongService(objectBox.store)),
        Provider(create: (_) => LoadingService(objectBox.store)),
        Provider(create: (_) => DatabaseService(objectBox.store)),
        Provider(create: (_) => StructureService(objectBox.store)),
        ChangeNotifierProvider<AudioService>.value(value: audioService),
        ChangeNotifierProvider(
          create: (context) => TracksProvider(context.read<AudioService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ControlsProvider(context.read<AudioService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => SongProvider(context.read<SongService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AudioProvider(context.read<AudioService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => StructureProvider(
            context.read<AudioService>(),
            context.read<DatabaseService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final audioService = context.read<AudioService>();
            final loadingService = context.read<LoadingService>();

            debugPrint('Audio desde Provider: $audioService');
            debugPrint('LoadingService desde Provider: $loadingService');

            return LoadingProvider(audioService, loadingService);
          },
        ),
      ],
      child: const Application(),
    ),
  );
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    supportedLocales: FLocalizations.supportedLocales,
    localizationsDelegates: const [...FLocalizations.localizationsDelegates],
    theme: lightTheme.toApproximateMaterialTheme(),
    darkTheme: darkTheme.toApproximateMaterialTheme(),
    builder: (context, child) => FTheme(
      data: Theme.brightnessOf(context) == .light ? lightTheme : darkTheme,
      child: FToaster(child: FTooltipGroup(child: child!)),
    ),
    // You can also replace FScaffold with Material Scaffold.
    home: const HomeScreen(),
  );
}
