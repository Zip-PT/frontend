import 'package:flutter/foundation.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';
import '../services/audio_service.dart';
import '../services/photo_service.dart';

class PropertyRecord {
  String id; // 각 기록의 고유 ID
  String title; // 매물 제목
  DateTime createdAt; // 생성 시간
  LocationInfo? locationInfo; // 위치 정보
  Map<String, String> checklistAnswers; // 체크리스트 응답 (질문 ID : 선택된 태그)
  SensorData? sensorData;
  AudioSummary? audioSummary;
  List<String> photosPaths; // 사진 파일 경로 목록
  String memo = '';

  PropertyRecord({
    required this.id,
    required this.title,
    required this.createdAt,
    this.locationInfo,
    this.sensorData,
    Map<String, String>? checklistAnswers,
    this.audioSummary,
    List<String>? photosPaths,
    this.memo = '',
  })  : checklistAnswers = checklistAnswers ?? {},
        photosPaths = photosPaths ?? [];

  // JSON 변환을 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'locationInfo': locationInfo != null
          ? {
              'address': locationInfo!.address,
              'nearestSubway': locationInfo!.nearestSubway?.toJson(),
              'convenienceStoreCount': locationInfo!.convenienceStoreCount,
              'busStopCount': locationInfo!.busStopCount,
            }
          : null,
      'checklistAnswers': checklistAnswers,
      'sensorData': sensorData != null
          ? {
              'humidity': sensorData!.humidity,
              'light': sensorData!.light,
              'temperature': sensorData!.temperature,
            }
          : null,
      'audioSummary': audioSummary != null
          ? {
              'transcription': audioSummary!.transcription,
              'summary': audioSummary!.summary,
            }
          : null,
      'photosPaths': photosPaths,
    };
  }

  factory PropertyRecord.fromJson(Map<String, dynamic> json) {
    return PropertyRecord(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      locationInfo: json['locationInfo'] != null
          ? LocationInfo.fromJson({'data': json['locationInfo']})
          : null,
      checklistAnswers: Map<String, String>.from(json['checklistAnswers']),
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

class PropertyProvider with ChangeNotifier {
  final List<PropertyRecord> _records = [
    // PropertyRecord(
    //   id: '1',
    //   title: '영상강 뷰 완전 좋은 단독주택',
    //   createdAt: DateTime(2024, 3, 1),
    //   locationInfo: LocationInfo.fromJson({
    //     'data': {
    //       'address': '복당시 북당읍 북당리 북당마을 2단지 초가집 2호',
    //       'nearestSubway': {
    //         'name': '북당역',
    //         'distance': 350,
    //         'distance_unit': 'm',
    //         'walking_time': 5,
    //         'time_unit': 'min',
    //         'location': {'lat': 37.123, 'lng': 127.123},
    //       },
    //       'convenienceStoreCount': 3,
    //       'busStopCount': 5,
    //     }
    //   }),
    //   checklistAnswers: {
    //     '채광': '매우 좋음',
    //     '환기': '좋음',
    //     '소음': '조용함',
    //   },
    //   sensorData: SensorData(temperature: 23.5, humidity: 45, light: "800 lux"),
    //   photosPaths: [
    //     "assets/images/house_image1.jpg"
    //   ], // 실제 앱에서는 여기에 실제 이미지 경로를 넣어주세요
    // )
  ];
  PropertyRecord? _currentRecord;
  bool _isLocationLoading = false; // 위치 정보 로딩 상태
  bool _isSensorLoading = false; // 센서 데이터 로딩 상태
  bool _isAudioLoading = false;
  bool _isPhotoLoading = false;

  // Getters
  List<PropertyRecord> get records => _records;
  PropertyRecord? get currentRecord => _currentRecord;
  bool get isLocationLoading => _isLocationLoading;
  bool get isSensorLoading => _isSensorLoading;
  bool get isAudioLoading => _isAudioLoading;
  bool get isPhotoLoading => _isPhotoLoading;

  // 새 기록 시작
  void startNewRecord() {
    _currentRecord = PropertyRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  // 제목 업데이트
  void updateTitle(String title) {
    if (_currentRecord != null) {
      _currentRecord!.title = title;
      notifyListeners();
    }
  }

  // 체크리스트 응답 업데이트
  void updateChecklistAnswer(String title, String tag) {
    if (_currentRecord != null) {
      _currentRecord!.checklistAnswers[title] = tag;
      notifyListeners();
    }
  }

  // 위치 정보 가져오기
  Future<void> fetchLocationInfo() async {
    if (_currentRecord == null) return;

    _isLocationLoading = true;
    notifyListeners();

    try {
      final locationService = LocationService();
      final response = await locationService.getCurrentLocationInfo();
      _currentRecord!.locationInfo = LocationInfo.fromJson(response);
    } catch (e) {
      print('위치 정보 조회 실패: $e');
    } finally {
      _isLocationLoading = false;
      notifyListeners();
    }
  }

  // 현재 기록 저장
  void saveCurrentRecord() {
    if (_currentRecord != null) {
      final existingIndex =
          _records.indexWhere((r) => r.id == _currentRecord!.id);
      if (existingIndex >= 0) {
        _records[existingIndex] = _currentRecord!;
      } else {
        _records.add(_currentRecord!);
      }
      notifyListeners();
    }
  }

  // 기록 삭제
  void deleteRecord(String id) {
    _records.removeWhere((record) => record.id == id);
    notifyListeners();
  }

  // 기록 수정을 위해 불러오기
  void loadRecordForEditing(String id) {
    final record = _records.firstWhere((r) => r.id == id);
    _currentRecord = PropertyRecord(
      id: record.id,
      title: record.title,
      createdAt: record.createdAt,
      locationInfo: record.locationInfo,
      checklistAnswers: Map.from(record.checklistAnswers),
    );
    notifyListeners();
  }

  // 모든 기록 불러오기 (나중에 로컬 저장소나 서버에서 불러올 때 사용)
  Future<void> loadRecords() async {
    // TODO: 실제 데이터 로딩 구현
    notifyListeners();
  }

  Future<void> fetchSensorData() async {
    if (_currentRecord == null) return;

    _isSensorLoading = true;
    notifyListeners();

    try {
      final sensorService = SensorService();
      final sensorData = await sensorService.getSensorData();
      _currentRecord!.sensorData = sensorData;
    } catch (e) {
      print('센서 데이터 조회 실패: $e');
    } finally {
      _isSensorLoading = false;
      notifyListeners();
    }
  }

  Future<void> processAudioRecord(String audioPath) async {
    if (_currentRecord == null) return;

    _isAudioLoading = true;
    notifyListeners();

    try {
      final audioService = AudioService();
      final summary = await audioService.processAudio(audioPath);
      _currentRecord!.audioSummary = summary;
    } catch (e) {
      print('오디오 처리 실패: $e');
    } finally {
      _isAudioLoading = false;
      notifyListeners();
    }
  }

  Future<void> takePhoto() async {
    if (_currentRecord == null) return;

    _isPhotoLoading = true;
    notifyListeners();

    try {
      final photoService = PhotoService();
      final photoPath = await photoService.takePhoto();

      if (photoPath != null) {
        _currentRecord!.photosPaths.add(photoPath);
      }
    } catch (e) {
      print('사진 촬영 실패: $e');
    } finally {
      _isPhotoLoading = false;
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    if (_currentRecord != null &&
        index >= 0 &&
        index < _currentRecord!.photosPaths.length) {
      _currentRecord!.photosPaths.removeAt(index);
      notifyListeners();
    }
  }

  void removeChecklistAnswer(String title) {
    if (_currentRecord != null) {
      _currentRecord!.checklistAnswers.remove(title);
      notifyListeners();
    }
  }
}
