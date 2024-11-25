import 'package:dio/dio.dart';

import 'api_keys.dart';

class WeatherService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getWeather(String city) async {
    const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'q': city,
          'appid': openWeatherApiKey,
          'units': 'metric',
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch weather: $e');
    }
  }

  Future<Map<String, dynamic>> getForecast(String city) async {
    const String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'q': city,
          'appid': openWeatherApiKey,
          'units': 'metric',
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch forecast: $e');
    }
  }
}
