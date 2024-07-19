import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ElevenLabsService {
  final String apiKey = '0ff748f185be57d2f1243199016aba3b';

  Future<String> generateAudio(String text) async {
    final response = await http.post(
      Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/5O30UBjxWW1lyQDCfejT'),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {"stability": 0.15, "similarity_boost": 0.75}
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final audioFile = await _saveAudioFile(bytes);
      return audioFile.path;
    } else {
      throw Exception('Failed to generate audio');
    }
  }

  Future<File> _saveAudioFile(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/audio.wav';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return file;
  }
}
