class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final int pressure;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      pressure: json['main']['pressure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
    };
  }
}