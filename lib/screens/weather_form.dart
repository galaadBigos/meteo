import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meteo/models/city_data.dart';
import 'package:meteo/models/weather_data.dart';
import 'package:meteo/screens/map_details.dart';
import 'package:meteo/services/city_service.dart';
import 'package:meteo/services/meteo_service.dart';

class WeatherForm extends StatefulWidget {
  const WeatherForm({super.key});

  @override
  State<WeatherForm> createState() => _WeatherFormState();
}

class _WeatherFormState extends State<WeatherForm> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  Future<CityData?>? _cityDataFuture;
  CityData? city;
  List<String> _lastCities = [];

  @override
  void initState() {
    super.initState();
    _loadLastCities();
  }

  Future<void> _loadLastCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastCities = prefs.getStringList('lastCities') ?? [];
    });
  }

  Future<void> _saveLastCity(String cityName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_lastCities.contains(cityName)) {
      _lastCities.remove(cityName);
    }
    _lastCities.insert(0, cityName);
    if (_lastCities.length > 5) {
      _lastCities = _lastCities.sublist(0, 5);
    }
    await prefs.setStringList('lastCities', _lastCities);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Météo'),
      ),
      body: _buildWeatherForm(),
    );
  }

  Padding _buildWeatherForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Saisissez le nom de la ville'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir le nom d\'une ville';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _getWeatherByCity,
                  child: const Text('Confirmer'),
                ),
                if (_cityDataFuture != null) _buildCityFutureBuilder(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_lastCities.isNotEmpty)
            Wrap(
              spacing: 8.0,
              children: _lastCities.map((city) {
                return ElevatedButton(
                  onPressed: () {
                    _cityController.text = city;
                    _getWeatherByCity();
                  },
                  child: Text(city),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (city == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MapDetails()));
              } else {
                double latitude = city!.latitude;
                double longitude = city!.longitude;
                Navigator.push(context, MaterialPageRoute(builder: (context) => MapDetails(latitude: latitude, longitude: longitude)));
              }
            },
            child: const Text('Voir la carte'),
          ),
        ],
      ),
    );
  }

  Future<void> _getWeatherByCity() async {
    if (_formKey.currentState!.validate()) {
      String cityName = _cityController.text;
      setState(() {
        _cityDataFuture = CityService.getCityByName(cityName);
      });
      await _saveLastCity(cityName);
    }
  }

  FutureBuilder<CityData?> _buildCityFutureBuilder() {
    return FutureBuilder(
      future: _cityDataFuture,
      builder: (BuildContext context, AsyncSnapshot<CityData?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: SnackBar(
              content: Text('Erreur: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData) {
          city = snapshot.data!;
          return _getWeatherBuilder(city!);
        } else {
          return const Center(child: Text('La météo de cette ville n\'est pas disponible'));
        }
      },
    );
  }

  FutureBuilder<WeatherData?> _getWeatherBuilder(CityData city) {
    return FutureBuilder(
      future: MeteoService.getWeatherByCoordinate(city.latitude, city.longitude),
      builder: (BuildContext context, AsyncSnapshot<WeatherData?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: SnackBar(
              content: Text('Erreur: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData) {
          return Center(child: Text(snapshot.data!.toString()));
        } else {
          return const Center(child: Text('La météo de cette ville n\'est pas disponible'));
        }
      },
    );
  }
}
