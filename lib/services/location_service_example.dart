// final locationService = LocationService();
// try {
//   final locationInfo = await locationService.getCurrentLocationInfo();
  
//   print('주소: ${locationInfo.address}');
  
//   if (locationInfo.nearestSubway != null) {
//     print('가까운 지하철역: ${locationInfo.nearestSubway!.name}');
//     print('도보 거리: ${locationInfo.nearestSubway!.distance}${locationInfo.nearestSubway!.distanceUnit}');
//     print('도보 시간: ${locationInfo.nearestSubway!.walkingTime}${locationInfo.nearestSubway!.timeUnit}');
//   }
  
//   print('주변 편의점: ${locationInfo.convenienceStoreCount}개');
//   print('주변 버스정류장: ${locationInfo.busStopCount}개');
// } catch (e) {
//   print('오류: $e');
// }