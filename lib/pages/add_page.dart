import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../providers/checklist_provider.dart';
import 'package:zippt/utils/colors.dart';
import 'dart:io';

class AddPropertyPage extends StatelessWidget {
  const AddPropertyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main,
      appBar: AppBar(
        title: const Text(
          '집 기록하기',
          style: TextStyle(
            fontFamily: 'GowunBatang',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.main,
        scrolledUnderElevation: 0,
        actions: [
          Consumer<PropertyProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: () {
                  if (provider.currentRecord?.title.isEmpty ?? true) {
                    // 제목이 비어있는 경우 경고
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('기록의 제목을 입력해주세요.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  // 저장 실행
                  provider.saveCurrentRecord();

                  // 새로운 기록 시작
                  provider.startNewRecord();

                  // 저장 완료 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('저장되었습니다.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  '저장',
                  style: TextStyle(
                    fontFamily: 'GowunBatang',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: const AddPropertyForm(),
    );
  }
}

class AddPropertyForm extends StatefulWidget {
  const AddPropertyForm({super.key});

  @override
  State<AddPropertyForm> createState() => _AddPropertyFormState();
}

class _AddPropertyFormState extends State<AddPropertyForm> {
  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 새 기록만 시작
    Future.microtask(() {
      context.read<PropertyProvider>().startNewRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 상단 안내 메시지
          Container(
            decoration: BoxDecoration(
              color: AppColors.mainGrey,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.black54),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '방문하신 집의 정보를 기록해주세요!',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 스크롤 가능한 본문
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 제목 입력 카드
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: '기록 제목',
                          hintText: '예: OO동 신축 아파트',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) =>
                            context.read<PropertyProvider>().updateTitle(value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 각 섹션 카드들 (위치, 센서, 음성, 사진, 체크리스트)
                  // 모든 Card 위젯에 동일하게 적용:
                  // elevation: 0,
                  // color: Colors.white,
                  // padding: const EdgeInsets.all(16.0)

                  // 위치 정보 카드
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Consumer<PropertyProvider>(
                        builder: (context, provider, child) {
                          final locationInfo =
                              provider.currentRecord?.locationInfo;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '주변 인프라 정보',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (!provider.isLocationLoading)
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          provider.fetchLocationInfo(),
                                      icon: const Icon(
                                        Icons.location_on,
                                      ),
                                      label: const Text(
                                        '현재 위치 가져오기',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: _buttonStyle,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              if (provider.isLocationLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (locationInfo != null) ...[
                                Text(
                                  '주소',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(locationInfo.address),
                                const Divider(height: 24),
                                if (locationInfo.nearestSubway != null) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '가까운 지하철',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      Text(
                                        '${locationInfo.nearestSubway!.name} (도보 ${locationInfo.nearestSubway!.walkingTime}분)',
                                      ),
                                    ],
                                  ),
                                ],
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '반경 200m 내 편의점',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                        '${locationInfo.convenienceStoreCount}개'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '반경 500m 내 버스정류장',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text('${locationInfo.busStopCount}개'),
                                  ],
                                ),
                              ] else
                                const Text('위치 정보를 가져와주세요.'),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 센서 데이터 섹션
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Consumer<PropertyProvider>(
                        builder: (context, provider, child) {
                          final sensorData = provider.currentRecord?.sensorData;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '온습조도 측정',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (!provider.isSensorLoading)
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          provider.fetchSensorData(),
                                      icon: const Icon(Icons.sensors),
                                      label: const Text(
                                        '측정하기',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: _buttonStyle,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (provider.isSensorLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (sensorData != null) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '온도',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          Text('${sensorData.temperature}°C'),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '습도',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          Text('${sensorData.humidity}%'),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '조도',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(sensorData.lightLevel),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ] else
                                const Text('측정 버튼을 눌러 실내 환경을 측정해주세요.'),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 오디오 섹션
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Consumer<PropertyProvider>(
                        builder: (context, provider, child) {
                          final audioSummary =
                              provider.currentRecord?.audioSummary;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '음성 기록',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (!provider.isAudioLoading)
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        await provider.processAudioRecord(
                                            'assets/audio/memo.mp3');
                                      },
                                      icon: const Icon(Icons.mic),
                                      label: const Text(
                                        '음성 분석 ',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: _buttonStyle,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (provider.isAudioLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (audioSummary != null) ...[
                                Text(
                                  '요약',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(audioSummary.summary),
                                const Divider(height: 24),
                                Text(
                                  '전체 텍스트',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  audioSummary.transcription,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ] else
                                const Text('음성 분석 버튼을 눌러 메모를 기록해주세요.'),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 사진 섹션
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Consumer<PropertyProvider>(
                        builder: (context, provider, child) {
                          final photos =
                              provider.currentRecord?.photosPaths ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '사진',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (!provider.isPhotoLoading)
                                    ElevatedButton.icon(
                                      onPressed: () => provider.takePhoto(),
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text(
                                        '촬영하기',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: _buttonStyle,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (provider.isPhotoLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (photos.isNotEmpty)
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: photos.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Stack(
                                          children: [
                                            Image.file(
                                              File(photos[index]),
                                              height: 120,
                                              width: 120,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    provider.removePhoto(index),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              else
                                const Text('촬영 버튼을 눌러 사진을 추가해주세요.'),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // 사진 섹션 아래에 추가
                  const SizedBox(height: 8),

                  // 체크리스트 섹션
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Consumer2<PropertyProvider, ChecklistProvider>(
                        builder: (context, propertyProvider, checklistProvider,
                            child) {
                          final checklistItems =
                              checklistProvider.checklistItems;
                          final answers = propertyProvider
                                  .currentRecord?.checklistAnswers ??
                              {};

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '체크리스트',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: checklistItems.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 24),
                                itemBuilder: (context, index) {
                                  final item = checklistItems[index];
                                  final selectedTag = answers[item['title']];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          for (String tag in item['tags'])
                                            ChoiceChip(
                                              label: Text(tag),
                                              selected: selectedTag == tag,
                                              onSelected: (selected) {
                                                if (selected) {
                                                  propertyProvider
                                                      .updateChecklistAnswer(
                                                    item['title'],
                                                    tag,
                                                  );
                                                } else {
                                                  propertyProvider
                                                      .removeChecklistAnswer(
                                                    item['title'],
                                                  );
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 버튼 스타일 상수 추가 (클래스 상단에)
final _buttonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.grey[100],
  foregroundColor: Colors.black87,
  elevation: 0,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
);
