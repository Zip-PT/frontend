// final weatherService = WeatherService();
// try {
//   final weatherInfo = await weatherService.getCurrentWeather();
  
//   print('도시: ${weatherInfo.city}');
//   print('날씨: ${weatherInfo.description}');
//   print('현재 기온: ${weatherInfo.currentTemp}°C');
//   print('체감 온도: ${weatherInfo.feelsLike}°C');
//   print('습도: ${weatherInfo.humidity}%');
//   print('날씨 아이콘 URL: ${weatherInfo.iconUrl}');
  
// } catch (e) {
//   print('오류: $e');
// }


// 날씨 아이콘

// Image.network(
//   weatherInfo.iconUrl,
//   width: 50,
//   height: 50,
//   errorBuilder: (context, error, stackTrace) {
//     return Icon(Icons.error);
//   },
// )