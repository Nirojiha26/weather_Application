import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WeatherDashboard());
}

class WeatherDashboard extends StatelessWidget {
  const WeatherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _indexController =
      TextEditingController(text: "224130C");

  double? latitude;
  double? longitude;

  bool isLoading = false;
  bool isCached = false;
  String? temperature;
  String? windSpeed;
  String? weatherCode;
  String? requestUrl;
  String? lastUpdated;
  String? errorMessage;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  IconData getWeatherIcon(String code) {
    switch (code) {
      case "0":
        return Icons.wb_sunny; // Clear sky
      case "1":
      case "2":
      case "3":
        return Icons.cloud; // Cloudy
      case "45":
      case "48":
        return Icons.foggy; // Fog
      case "51":
      case "61":
      case "63":
      case "80":
        return Icons.water_drop; // Rain
      case "71":
      case "73":
        return Icons.ac_unit; // Snow
      default:
        return Icons.cloud;
    }
  }

  Color getTempColor(double temp) {
    if (temp <= 15) return Colors.blue;
    if (temp <= 28) return Colors.green;
    return Colors.red;
  }

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      isCached = false;
    });

    final index = _indexController.text.toUpperCase().trim();
    if (index.length < 4) {
      setState(() {
        errorMessage = "Index must be at least 4 characters.";
        isLoading = false;
      });
      return;
    }

    // Calculate latitude & longitude
    final firstTwo = int.tryParse(index.substring(0, 2));
    final nextTwo = int.tryParse(index.substring(2, 4));
    if (firstTwo == null || nextTwo == null) {
      setState(() {
        errorMessage = "Invalid index format.";
        isLoading = false;
      });
      return;
    }

    latitude = 5 + firstTwo / 10.0;
    longitude = 79 + nextTwo / 10.0;

    final url =
        "https://api.open-meteo.com/v1/forecast?latitude=${latitude!.toStringAsFixed(2)}&longitude=${longitude!.toStringAsFixed(2)}&current_weather=true";
    setState(() => requestUrl = url);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = data['current_weather'];

        temperature = weather['temperature'].toString();
        windSpeed = weather['windspeed'].toString();
        weatherCode = weather['weathercode'].toString();
        lastUpdated =
            "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('temperature', temperature!);
        prefs.setString('windSpeed', windSpeed!);
        prefs.setString('weatherCode', weatherCode!);
        prefs.setString('latitude', latitude!.toStringAsFixed(2));
        prefs.setString('longitude', longitude!.toStringAsFixed(2));
        prefs.setString('requestUrl', requestUrl!);
        prefs.setString('lastUpdated', lastUpdated!);

        _fadeController.forward(from: 0); // animate card
      } else {
        await loadCache(error: "Failed to fetch weather.");
      }
    } catch (e) {
      await loadCache(error: "Error: ${e.toString()}");
    }

    setState(() => isLoading = false);
  }

  Future<void> loadCache({String? error}) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTemp = prefs.getString('temperature');

    if (cachedTemp != null) {
      temperature = prefs.getString('temperature');
      windSpeed = prefs.getString('windSpeed');
      weatherCode = prefs.getString('weatherCode');
      latitude = double.tryParse(prefs.getString('latitude') ?? '');
      longitude = double.tryParse(prefs.getString('longitude') ?? '');
      requestUrl = prefs.getString('requestUrl');
      lastUpdated = prefs.getString('lastUpdated');
      isCached = true;
      errorMessage = error;

      _fadeController.forward(from: 0);
    } else {
      errorMessage = error ?? "No cached data available.";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 4,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
              Colors.blue.shade200,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _indexController,
              decoration: InputDecoration(
                labelText: "Student Index",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modern wide button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : fetchWeather,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Fetch Weather",
                        style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 16),

            if (latitude != null)
              Text(
                "Lat: ${latitude!.toStringAsFixed(2)} | Lon: ${longitude!.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            if (temperature != null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          getWeatherIcon(weatherCode!),
                          size: 80,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Temperature: $temperature °C",
                          style: TextStyle(
                            fontSize: 22,
                            color: getTempColor(double.parse(temperature!)),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Wind Speed: $windSpeed km/h",
                            style: const TextStyle(fontSize: 18)),
                        Text("Weather Code: $weatherCode",
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text(
                          "Last Updated: $lastUpdated ${isCached ? "(cached)" : ""}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
