class Movie {
  final String id;
  final String title;
  final String? description;
  final String? posterUrl;
  final int? year;

  Movie({
    required this.id,
    required this.title,
    this.description,
    this.posterUrl,
    this.year,
  });

  factory Movie.fromMap(String id, Map<String, dynamic> map) {
    return Movie(
      id: id,
      title: map['title'] ?? 'Unknown',
      description: map['description'] as String?,
      posterUrl: map['posterUrl'] as String?,
      year: map['year'] is int ? map['year'] as int : int.tryParse(map['year']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'year': year,
    };
  }
}
