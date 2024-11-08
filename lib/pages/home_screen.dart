import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F4),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WeatherCard(),
              const SizedBox(height: 20),
              const Text(
                '내가 봤던 집',
                style: TextStyle(
                  fontFamily: 'GowunBatang', // GowunBatang 폰트 사용
                  fontWeight: FontWeight.bold, // Bold 스타일 적용
                  fontSize: 20, // 텍스트 크기 설정
                ),
              ),
              const SizedBox(height: 10),
              // houses 리스트를 통해 ListView.builder로 HouseCard 표시
              ListView.builder(
                shrinkWrap: true, // SingleChildScrollView 내에서 스크롤 제한
                physics: const NeverScrollableScrollPhysics(), // 스크롤 중복 방지
                itemCount: houses.length,
                itemBuilder: (context, index) {
                  return HouseCard(house: houses[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String city = '';
  String temperature = '';
  String feelsLike = '';
  String description = '';
  String humidity = '';
  String iconUrl = '';

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final url = Uri.parse('http://210.125.84.145:8000/api/weather');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "latitude": 34.7,
        "longitude": 126.9780,
      }),
    );

    // mounted 체크 추가
    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        city = data['city'];
        temperature = "${data['temperature']['current']}°";
        feelsLike = "체감 ${data['temperature']['feels_like']}°";
        description = data['weather']['description'];
        humidity = "습도 ${data['humidity']}%";
        iconUrl = data['weather']['icon'];
      });
    } else {
      print('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFFFCDD2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "오늘의 날씨 - $city",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              iconUrl.isNotEmpty
                  ? Image.network(iconUrl, width: 40, height: 40)
                  : const Icon(Icons.wb_cloudy, size: 40),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temperature,
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  Text(description),
                  Text(feelsLike,
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  const Text("일요일 | 11월 7일"), // 예시 날짜 (서버에서 날짜 데이터를 받지 않는 경우)
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.opacity, size: 16),
                      Text(humidity),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final List<House> houses = [
  House(
    title: '영상강 뷰 완전 좋은 단독주택',
    date: '1999년 11월 1일 오후 11시',
    address: '복당시 북당읍 북당리 북당마을 2단지 초가집 2호',
    imageUrl: 'assets/images/house_image1.jpg',
  ),
  House(
    title: '배산임수 풍수 최고 단독주택',
    date: '2000년 12월 2일 오후 2시',
    address: '광주광역시 북구 첨단과기로123 1호',
    imageUrl: 'assets/images/house_image2.jpg',
  ),
  House(
    title: '사과농장 뷰 달콤 단독주택',
    date: '2001년 1월 3일 오후 3시',
    address: '복당시 동당읍 동당리 동당마을 4단지 초가집 3호',
    imageUrl: 'assets/images/house_image3.jpg',
  ),
];

class HouseCard extends StatelessWidget {
  final House house;

  const HouseCard({super.key, required this.house});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // WeatherCard와 동일한 너비 설정
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10.0)),
              child: Image.asset(
                house.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    house.title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    house.date,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    house.address,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class House {
  final String title;
  final String date;
  final String address;
  final String imageUrl;

  House({
    required this.title,
    required this.date,
    required this.address,
    required this.imageUrl,
  });
}
