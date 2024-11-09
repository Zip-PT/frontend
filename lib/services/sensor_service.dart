import 'package:http/http.dart' as http;
import 'dart:convert';

class SensorData {
  final double humidity;
  final String light;
  final String lightLevel;
  final double temperature;

  SensorData({
    required this.humidity,
    required this.light,
    required this.temperature,
  }) : lightLevel = _getLightLevel(light);

  static String _getLightLevel(String lightStr) {
    final luxValue = double.parse(lightStr.split(' ')[0]);

    if (luxValue < 1) {
      return '매우 어두움';
    } else if (luxValue < 50) {
      return '어두움';
    } else if (luxValue < 100) {
      return '평범함';
    } else if (luxValue < 500) {
      return '밝음';
    } else {
      return '매우 밝음';
    }
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      humidity: json['humidity'].toDouble(),
      light: json['light'].toString(),
      temperature: json['temperature'].toDouble(),
    );
  }
}

class SensorService {
  static final SensorService _instance = SensorService._internal();
  final String baseUrl = 'http://bokdung.local:5000';

  factory SensorService() {
    return _instance;
  }

  SensorService._internal();

  Future<SensorData> getSensorData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sensor'));

      if (response.statusCode == 200) {
        return SensorData.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('센서 데이터 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('센서 데이터 조회 중 오류 발생: $e');
    }
  }
}
