import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioSummary {
  final String transcription; // 음성 텍스트 변환 결과
  final String summary; // GPT 요약 결과

  AudioSummary({
    required this.transcription,
    required this.summary,
  });

  factory AudioSummary.fromJson(Map<String, dynamic> json) {
    return AudioSummary(
      transcription: json['transcription'],
      summary: json['summary'],
    );
  }
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final String baseUrl = 'http://210.125.84.145:8000';

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  // asset 파일을 임시 파일로 복사하는 헬퍼 메서드
  Future<String> _getAudioFilePath(String assetPath) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/temp_audio.mp3';

    final byteData = await rootBundle.load(assetPath);
    final file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    ));

    return filePath;
  }

  Future<AudioSummary> processAudio(String assetPath) async {
    try {
      final url = Uri.parse('$baseUrl/api/summarise-audio');
      final audioPath = await _getAudioFilePath(assetPath);

      var request = http.MultipartRequest('POST', url);
      request.files
          .add(await http.MultipartFile.fromPath('audio_file', audioPath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      await File(audioPath).delete(); // 임시 파일 삭제

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(decodedBody);
        return AudioSummary.fromJson(jsonResponse);
      } else {
        throw Exception('오디오 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오디오 처리 중 오류 발생: $e');
    }
  }
}
