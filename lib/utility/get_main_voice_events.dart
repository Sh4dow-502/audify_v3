import 'package:audify_v3/models/voice_event.dart';

List<VoiceEvent> getMainVoiceEvents(List<VoiceEvent> events) {
  return events
      .asMap()
      .entries
      .where(
        (entry) => entry.key % 5 == 0,
      ) // 0, 5, 10, 15... (que son el 1ro, 6to, 11vo...)
      .map((entry) => entry.value)
      .toList();
}
