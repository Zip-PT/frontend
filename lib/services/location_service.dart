import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:zippt/utils/gps.dart';

class LocationService {
  // 싱글톤 패턴 구현
  static final LocationService _instance = LocationService._internal();
  final String baseUrl = 'http://210.125.84.145:8000';

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  // GPS로 현재 lat, long 좌표 가져오기
  Future<Position?> getCurrentLocation() async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }

      // 위치 정보 가져오기
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      throw Exception('위치 정보를 가져오는데 실패했습니다: $e');
    }
  }

  // GPS 정보를 input으로 주면 해당 위치 기반 인프라 정보 반환
  Future<Map<String, dynamic>> getLocationInfo(Position position) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/location-info'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(gps),
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        return jsonDecode(decodedBody);
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('위치 정보 조회 실패: $e');
    }
  }

  // GPS 정보 가져와서 현재 위치 기반 인프라 정보 반환하는 함수 호출 및 반환
  Future<Map<String, dynamic>> getCurrentLocationInfo() async {
    final position = await getCurrentLocation();
    if (position == null) {
      throw Exception('현재 위치를 가져올 수 없습니다.');
    }
    return await getLocationInfo(position);
  }
}

class LocationInfo {
  final String address;
  final SubwayInfo? nearestSubway;
  final int convenienceStoreCount;
  final int busStopCount;

  LocationInfo({
    required this.address,
    this.nearestSubway,
    required this.convenienceStoreCount,
    required this.busStopCount,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LocationInfo(
      address: data['address'],
      nearestSubway: data['nearest_subway'] != null
          ? SubwayInfo.fromJson(data['nearest_subway'])
          : null,
      convenienceStoreCount: data['convenience_store']["count"],
      busStopCount: data['nearest_busstop']["count"],
    );
  }
}

class SubwayInfo {
  final String name;
  final int distance;
  final String distanceUnit;
  final int walkingTime;
  final String timeUnit;
  final Map<String, double> location;

  SubwayInfo({
    required this.name,
    required this.distance,
    required this.distanceUnit,
    required this.walkingTime,
    required this.timeUnit,
    required this.location,
  });

// toJson 메서드 추가
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'distance': distance,
      'distance_unit': distanceUnit,
      'walking_time': walkingTime,
      'time_unit': timeUnit,
      'location': location,
    };
  }

  factory SubwayInfo.fromJson(Map<String, dynamic> json) {
    return SubwayInfo(
      name: json['name'],
      distance: json['distance'],
      distanceUnit: json['distance_unit'],
      walkingTime: json['walking_time'],
      timeUnit: json['time_unit'],
      location: {
        'lat': json['location']['lat'],
        'lng': json['location']['lng'],
      },
    );
  }
}
