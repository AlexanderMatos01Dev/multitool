import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String _errorMessage = '';
  final String _city = 'Santo Domingo';
  final String _country = 'DO';

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      const apiKey = 'f2402900c837da8403c469473db51397';
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$_city,$_country&appid=$apiKey&units=metric&lang=es'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() => _weatherData = json.decode(response.body));
      } else {
        setState(() => _errorMessage = 'Error ${response.statusCode}: No se pudo obtener datos del clima');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error de conexión: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima en República Dominicana'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeather,
          )
        ],
      ),
      body: _buildWeatherBody(),
    );
  }

  Widget _buildWeatherBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchWeather,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final weather = _weatherData!['weather'][0];
    final main = _weatherData!['main'];
    final wind = _weatherData!['wind'];
    final sys = _weatherData!['sys'];

    final description = weather['description'];
    final temperature = main['temp'];
    final feelsLike = main['feels_like'];
    final humidity = main['humidity'];
    final pressure = main['pressure'];
    final windSpeed = wind['speed'];
    final iconCode = weather['icon'];
    final sunrise = sys['sunrise'];
    final sunset = sys['sunset'];

    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@4x.png';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getBackgroundColors(temperature),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ubicación
            Text(
              '$_city, $_country',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              _getFormattedDate(),
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),

            // Temperatura e ícono
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(iconUrl, width: 120, height: 120),
                const SizedBox(width: 20),
                Text(
                  '${temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Descripción
            Text(
              description.toString().toUpperCase(),
              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),

            // Sensación térmica
            Text(
              'Sensación: ${feelsLike.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 40),

            // Detalles del clima
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailItem(Icons.water_drop, 'Humedad', '$humidity%'),
                        _buildDetailItem(Icons.air, 'Viento', '${windSpeed.toStringAsFixed(1)} m/s'),
                        _buildDetailItem(Icons.speed, 'Presión', '$pressure hPa'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSunItem(Icons.wb_sunny, 'Amanecer', sunrise),
                        _buildSunItem(Icons.nightlight, 'Atardecer', sunset),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    final day = now.day;

    final hour = now.hour;
    final minute = now.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return '$weekday $day de $month, $hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 36, color: Colors.white),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildSunItem(IconData icon, String title, int timestamp) {
    final time = _formatTime(timestamp);
    return Column(
      children: [
        Icon(icon, size: 36, color: Colors.white),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(time, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ],
    );
  }

  List<Color> _getBackgroundColors(double temperature) {
    if (temperature > 30) {
      return [const Color(0xFFFF7E5F), const Color(0xFFFEB47B)]; // Caluroso
    } else if (temperature > 20) {
      return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)]; // Templado
    } else if (temperature > 10) {
      return [const Color(0xFF3494E6), const Color(0xFFEC6EAD)]; // Fresco
    } else {
      return [const Color(0xFF2193B0), const Color(0xFF6DD5ED)]; // Frío
    }
  }
}