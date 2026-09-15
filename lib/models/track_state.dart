class TrackState {
  final double volume; // 0.0 a 1.0
  final bool isMuted;

  const TrackState({this.volume = 1.0, this.isMuted = false});

  // El volumen real que se envía al motor de C++ (SoLoud)
  double get effectiveVolume => isMuted ? 0.0 : volume;

  TrackState copyWith({double? volume, bool? isMuted}) {
    return TrackState(
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}
