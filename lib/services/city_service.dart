import 'package:meteo/models/city_data.dart';
import 'package:meteo/models/meteo_data.dart';

class CityService {
  static final MeteoData _meteoData = MeteoData();

  static Future<CityData?> getCityByName(String cityName) async
    => await _meteoData.fetchCity(cityName);
}