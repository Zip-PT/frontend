import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zippt/utils/colors.dart';
import 'package:zippt/utils/gps.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:zippt/providers/property_provider.dart';
import 'package:zippt/pages/property_detail_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내가 본 집 기록',
          style: TextStyle(
            fontFamily: 'GowunBatang',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.main,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: const Color(0xFFF9F8F4),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WeatherCard(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '내가 봤던 집',
                    style: TextStyle(
                      fontFamily: 'GowunBatang',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '총 ${context.watch<PropertyProvider>().records.length}곳',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<PropertyProvider>(
                builder: (context, provider, child) {
                  final records = provider.records;
                  if (records.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.home_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              '아직 기록된 매물이 없습니다.\n새로운 매물을 기록해보세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PropertyDetailPage(record: record),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (record.photosPaths.isNotEmpty)
                                SizedBox(
                                  height: 200,
                                  child: PageView.builder(
                                    itemCount: record.photosPaths.length,
                                    itemBuilder: (context, photoIndex) {
                                      return Image.file(
                                        File(record.photosPaths[photoIndex]),
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            record.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatDate(record.createdAt),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (record.locationInfo != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              record.locationInfo!.address,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (record.checklistAnswers.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          for (var entry in record
                                              .checklistAnswers.entries)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '${entry.key}: ${entry.value}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}'
        '.${date.day.toString().padLeft(2, '0')}';
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
    try {
      final url = Uri.parse('http://210.125.84.145:8000/api/weather');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(gps),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          city = data['city'] ?? '알 수 없음';
          temperature = "${data['temperature']?['current'] ?? ''}°";
          feelsLike = "체감 ${data['temperature']?['feels_like'] ?? ''}°";
          description = data['weather']?['description'] ?? '';
          humidity = "습도 ${data['humidity'] ?? ''}%";
          iconUrl = data['weather']?['icon'] ?? '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        city = '날씨 정보를 불러올 수 없습니다';
        temperature = '--°';
        feelsLike = '체감 --°';
        description = '';
        humidity = '습도 --%';
        iconUrl = '';
      });
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: Image.asset(
              house.imageUrl,
              height: 130,
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
