import 'package:audify_v3/models/voice_model.dart';

class VoiceEvent {
  final String id;
  final Duration position;
  final VoiceModel voice;
  final String groupId;

  const VoiceEvent({
    required this.id,
    required this.position,
    required this.voice,
    required this.groupId,
  });

  factory VoiceEvent.fromJson(Map<String, dynamic> json) {
    return VoiceEvent(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      position: Duration(milliseconds: json['positionMs'] ?? 0),
      voice: VoiceModel.fromJson(Map<String, dynamic>.from(json['voice'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {'positionMs': position.inMilliseconds, 'voice': voice.toJson()};
  }
}
