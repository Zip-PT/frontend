import 'package:flutter/material.dart';
import 'dart:io';
import '../providers/property_provider.dart';

class PropertyDetailPage extends StatelessWidget {
  final PropertyRecord record;

  const PropertyDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          record.title,
          style: const TextStyle(
            fontFamily: 'GowunBatang',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.photosPaths.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: record.photosPaths.length,
                  itemBuilder: (context, index) {
                    return Image.file(
                      File(record.photosPaths[index]),
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기본 정보
                  _buildSection('기본 정보', [
                    _buildInfoRow('방문 날짜', _formatDate(record.createdAt)),
                    if (record.locationInfo != null) ...[
                      _buildInfoRow('주소', record.locationInfo!.address),
                      if (record.locationInfo!.nearestSubway != null)
                        _buildInfoRow(
                          '가까운 지하철',
                          '${record.locationInfo!.nearestSubway!.name} (도보 ${record.locationInfo!.nearestSubway!.walkingTime}분)',
                        ),
                      _buildInfoRow(
                        '반경 200m 내 편의점',
                        '${record.locationInfo!.convenienceStoreCount}개',
                      ),
                      _buildInfoRow(
                        '반경 500m 내 버스정류장',
                        '${record.locationInfo!.busStopCount}개',
                      ),
                    ],
                  ]),

                  const SizedBox(height: 24),

                  // 센서 데이터
                  if (record.sensorData != null)
                    _buildSection('실내 환경', [
                      _buildInfoRow(
                          '온도', '${record.sensorData!.temperature}°C'),
                      _buildInfoRow('습도', '${record.sensorData!.humidity}%'),
                      _buildInfoRow('조도', '${record.sensorData!.light} lux'),
                    ]),

                  const SizedBox(height: 24),

                  // 체크리스트 답변
                  if (record.checklistAnswers.isNotEmpty)
                    _buildSection('체크리스트', [
                      for (var entry in record.checklistAnswers.entries)
                        _buildInfoRow(entry.key, entry.value),
                    ]),

                  const SizedBox(height: 24),

                  // 음성 분석 결과
                  if (record.audioSummary != null)
                    _buildSection('음성 메모 분석', [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '요약',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(record.audioSummary!.summary),
                            const SizedBox(height: 16),
                            Text(
                              '전체 텍스트',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(record.audioSummary!.transcription),
                          ],
                        ),
                      ),
                    ]),

                  const SizedBox(height: 24),

                  // 메모
                  if (record.memo.isNotEmpty)
                    _buildSection('메모', [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(record.memo),
                      ),
                    ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'GowunBatang',
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}'
        '.${date.day.toString().padLeft(2, '0')}';
  }
}
