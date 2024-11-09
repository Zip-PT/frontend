import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherInfo {
  final String city;
  final String description;
  final String iconUrl;
  final double currentTemp;
  final double feelsLike;
  final int humidity;

  WeatherInfo({
    required this.city,
    required this.description,
    required this.iconUrl,
    required this.currentTemp,
    required this.feelsLike,
    required this.humidity,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      city: json['city'],
      description: json['weather']['description'],
      iconUrl: json['weather']['icon'],
      currentTemp: json['temperature']['current'].toDouble(),
      feelsLike: json['temperature']['feels_like'].toDouble(),
      humidity: json['humidity'],
    );
  }
}

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  final String baseUrl = 'http://210.125.84.145:8000';

  factory WeatherService() {
    return _instance;
  }

  WeatherService._internal();

  Future<WeatherInfo> getWeatherInfo(Position position) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/weather'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        return WeatherInfo.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('날씨 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('날씨 정보 조회 중 오류 발생: $e');
    }
  }

  Future<WeatherInfo> getCurrentWeather() async {
    final position = await Geolocator.getCurrentPosition(
        locationSettings: AppleSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 5),
      activityType: ActivityType.fitness,
    ));
    return await getWeatherInfo(position);
  }
}
