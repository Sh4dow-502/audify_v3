Map<String, String> orderTracks(Map<String, String> tracks) {
  final priority = ['vocals', 'bass', 'drums', 'other'];

  final sortedMap = Map.fromEntries(
    tracks.entries.toList()..sort((a, b) {
      int indexA = priority.indexOf(a.key.toLowerCase());
      int indexB = priority.indexOf(b.key.toLowerCase());
      return (indexA == -1 ? 99 : indexA).compareTo(indexB == -1 ? 99 : indexB);
    }),
  );

  return sortedMap;
}

Map<String, Map<String, dynamic>> orderTracksWithDetails(
  Map<String, Map<String, dynamic>> tracks,
) {
  final priority = ['vocals', 'bass', 'piano', 'guitar', 'drums', 'other'];

  final sortedMap = Map.fromEntries(
    tracks.entries.toList()..sort((a, b) {
      int indexA = priority.indexOf(a.key.toLowerCase());
      int indexB = priority.indexOf(b.key.toLowerCase());
      return (indexA == -1 ? 99 : indexA).compareTo(indexB == -1 ? 99 : indexB);
    }),
  );

  return sortedMap;
}
