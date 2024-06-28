class CityData {
  late String name;
  late double latitude;
  late double longitude;
  late String country;
  late int population;
  late bool isCapital;

  CityData({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.population,
    required this.isCapital,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      name: json['name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      country: json['country'] as String,
      population: json['population'] as int,
      isCapital: json['is_capital'] as bool,
    );
  }
}
