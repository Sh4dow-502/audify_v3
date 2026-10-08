class VoiceModel {
  final String id;
  final String name;
  final String asset;

  const VoiceModel({required this.id, required this.name, required this.asset});

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      asset: json['asset'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'asset': asset};
  }
}
