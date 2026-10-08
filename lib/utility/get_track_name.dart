String getTrackName(String track) {
  switch (track) {
    case 'drums':
      return 'Batería';
    case 'vocals':
      return 'Voz';
    case 'bass':
      return 'Bajo';
    case 'guitar':
      return 'Guitarra';
    case 'piano':
      return 'Piano';
    case 'metronome':
      return 'Metrónomo';
    case 'guide':
      return 'Voz guia';
    default:
      return 'Otros';
  }
}
