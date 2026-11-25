/// Upcoming AI features people can join the waitlist for.
enum AiFeature {
  nameFinder('name_finder'),
  facePreview('face_preview');

  const AiFeature(this.code);

  /// Stored in Firestore / analytics.
  final String code;

  static AiFeature? fromCode(String code) {
    for (final AiFeature f in values) {
      if (f.code == code) return f;
    }
    return null;
  }
}
