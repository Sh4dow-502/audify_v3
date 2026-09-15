String formatDuration(int totalSeconds) {
  if (totalSeconds <= 0) return '0s';

  int hours = totalSeconds ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;

  List<String> parts = [];

  if (hours > 0) {
    parts.add('${hours}h');
  }
  if (minutes > 0) {
    parts.add('${minutes}m');
  }
  if (seconds > 0 || parts.isEmpty) {
    parts.add('${seconds}s');
  }

  return parts.join(' ');
}

String formatDurationV2(int totalSeconds) {
  // Ejemplo 3:17
  if (totalSeconds <= 0) return '0:00';

  int minutes = totalSeconds ~/ 60;
  int seconds = totalSeconds % 60;
  int hours = minutes ~/ 60;

  minutes = minutes % 60;
  String formattedDuration = '';

  if (hours > 0) {
    formattedDuration += '$hours:';
  }
  formattedDuration += '${minutes.toString().padLeft(1, '0')}:';
  formattedDuration += seconds.toString().padLeft(2, '0');

  return formattedDuration;
}
