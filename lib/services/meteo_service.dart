import 'package:meteo/models/meteo_data.dart';
import 'package:meteo/models/weather_data.dart';

class MeteoService {
    static final MeteoData _meteoData = MeteoData();

  static Future<WeatherData> getWeatherByCoordinate(double latitude, double longitude) async
    => await _meteoData.fetchWeather(latitude, longitude);
}