import 'package:flutter/material.dart';
import 'location_service.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  // 요런식으로 불러서 GPS 정보를 가져오시면 됩니다
  final LocationService _locationService = LocationService();
  String _locationMessage = '';

  Future<void> _getLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        _locationMessage = '''
현재 위치:
위도: ${position?.latitude}
경도: ${position?.longitude}
고도: ${position?.altitude}
정확도: ${position?.accuracy}m
''';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_locationMessage),
        ElevatedButton(
          onPressed: _getLocation,
          child: const Text('위치 가져오기'),
        ),
      ],
    );
  }
}
