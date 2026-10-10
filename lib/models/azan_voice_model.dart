class AzanVoiceModel {
  final String id;
  final String name;
  final String muadhin;
  final String location;
  final String description;
  final String audioUrl;
  final bool isFajr;
  final String durationText;

  const AzanVoiceModel({
    required this.id,
    required this.name,
    required this.muadhin,
    required this.location,
    required this.description,
    required this.audioUrl,
    this.isFajr = false,
    this.durationText = '৩:১৫ মিনিট',
  });
}
