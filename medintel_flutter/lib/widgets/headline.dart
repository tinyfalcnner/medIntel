// lib/models/headline.dart
class Headline {
  final String headline;
  final String category;
  final String source;

  Headline({required this.headline, required this.category, required this.source});

  factory Headline.fromJson(Map<String, dynamic> json) {
    return Headline(
      headline: json['headline'] ?? '',
      category: json['category'] ?? '',
      source: json['source'] ?? '',
    );
  }
}
