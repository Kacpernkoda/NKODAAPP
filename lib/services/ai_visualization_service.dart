import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AiVisualizationService {
  static final AiVisualizationService _instance = AiVisualizationService._internal();
  factory AiVisualizationService() => _instance;
  AiVisualizationService._internal();

  /// Wysyła zdjęcie i wybrany kolor do API (Gemini Nano Banana) 
  Future<Uint8List?> generateVehicleWrap({
    required Uint8List imageBytes,
    required String colorHex,
    required String colorName,
  }) async {
    // Hardcoded klucz podany przez inwestora - wyciągnięcie do środowiska nastąpi później
    const String apiKey = 'AIzaSyBMCFTukkrQyzwb0Aq8AjjUg0dEW-wnaBA';
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/nano-banana-pro-preview:generateContent?key=$apiKey');

    final base64Input = base64Encode(imageBytes);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "A perfect car visualization. Change the color of the car body EXACTLY to $colorName (hex #$colorHex). Keep reflections, lighting, background, and original car shape 100% intact. Output only the final colored car image."},
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Input
                }
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final candidates = jsonResponse['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts != null) {
          for (var part in parts) {
            if (part.containsKey('inlineData')) {
              return base64Decode(part['inlineData']['data']);
            }
          }
        }
      }
      return null;
    } else {
      throw Exception('Gemini API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
