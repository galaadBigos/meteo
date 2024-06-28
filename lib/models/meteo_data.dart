import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meteo/models/city_data.dart';
import 'package:meteo/models/weather_data.dart';

class MeteoData {



  Future<CityData?> fetchCity(String cityName) async {
    final response = await http.get(
      Uri.parse('https://api.api-ninjas.com/v1/city?name=$cityName'),
      headers: {
        'X-Api-Key': dotenv.env['CITY_API_KEY'] ?? '',
      },
    );
    try {
      final List<dynamic> json = jsonDecode(response.body);
      return CityData.fromJson(json[0]);
    } catch (ex) {
      return null;
    }
  }

  Future<WeatherData> fetchWeather(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=${dotenv.env['METEO_API_KEY']}'),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherData.fromJson(json as Map<String, dynamic>);
    } else {
      throw Exception('Erreur lors de la récupération de la météo');
    }
  }
}