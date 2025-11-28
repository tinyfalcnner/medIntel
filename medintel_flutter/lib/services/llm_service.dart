// lib/services/llm_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/headline.dart';

class LlmService {
  // Replace with your backend endpoint or LLM endpoint.
  static const String _endpoint =
      'https://api.your-backend.example.com/health-headlines';

  /// Fetches health headlines. The endpoint should return a JSON object:
  /// { "headlines": [ { "headline": "...", "category":"...", "source":"..." }, ... ] }
  static Future<List<Headline>> getHealthHeadlines() async {
    final uri = Uri.parse(_endpoint);
    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      // Include auth headers if needed
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      final items = (jsonBody['headlines'] as List?) ?? [];

      // Since Headline has no fromJson, build it manually
      return items.map((e) {
        final map = e as Map<String, dynamic>;
        return Headline(
          headline: map['headline'] as String? ?? '',
          category: map['category'] as String? ?? '',
          source: map['source'] as String? ?? '',
        );
      }).toList();
    } else {
      throw Exception('Failed to load headlines: ${response.statusCode}');
    }
  }
}
