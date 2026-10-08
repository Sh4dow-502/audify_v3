import 'dart:async';

import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/providers/audio_provider.dart';
import 'package:audify_v3/providers/loading_provider.dart';
import 'package:audify_v3/screens/player/components/loading_content.dart';
import 'package:audify_v3/screens/player/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  final SongEntity song;
  const LoadingScreen({super.key, required this.song});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final LoadingProvider _loadingProvider;
  Timer? _completionTimer;
  bool _showPlayer = false;

  @override
  void initState() {
    super.initState();

    _loadingProvider = context.read<LoadingProvider>();
    _showPlayer =
        _loadingProvider.songId == widget.song.songId &&
        _loadingProvider.loadinStep == "completed";
    if (!_showPlayer) {
      _loadingProvider.addListener(_handleLoadingState);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadingProvider.initLoading(widget.song);
      }
    });
  }

  void _handleLoadingState() {
    if (_loadingProvider.loadinStep != "completed" ||
        _showPlayer ||
        _completionTimer != null) {
      return;
    }

    _completionTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      context.read<AudioProvider>().setVoiceEvents(widget.song.voiceEvents);
      setState(() => _showPlayer = true);
    });
  }

  @override
  void dispose() {
    if (!_showPlayer) {
      _loadingProvider.removeListener(_handleLoadingState);
    }
    _completionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoadingProvider>().loadinStep;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 680),
      reverseDuration: const Duration(milliseconds: 460),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.82), weight: 35),
          TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.0), weight: 65),
        ]).animate(animation);
        final slide = Tween<Offset>(
          begin: const Offset(0.045, 0),
          end: Offset.zero,
        ).animate(animation);
        final scale = Tween<double>(begin: 0.985, end: 1.0).animate(animation);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
      child: state == "completed" && _showPlayer
          ? PlayerScreen(key: const ValueKey("player"), song: widget.song)
          : SafeArea(
              key: const ValueKey("loading"),
              child: FScaffold(
                header: FHeader.nested(
                  title: const Text("Cargando canción"),
                  titleAlignment: .centerLeft,
                  prefixes: [
                    FHeaderAction.back(onPress: () => Navigator.pop(context)),
                  ],
                ),
                child: LoadingContent(song: widget.song),
              ),
            ),
    );
  }
}
