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
      theme: ThemeData(primarySwatch: Colors.blue),
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

class _WeatherHomePageState extends State<WeatherHomePage> {
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

    setState(() {
      requestUrl = url;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = data['current_weather'];
        setState(() {
          temperature = weather['temperature'].toString();
          windSpeed = weather['windspeed'].toString();
          weatherCode = weather['weathercode'].toString();
          lastUpdated =
              "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";
        });

        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('temperature', temperature!);
        prefs.setString('windSpeed', windSpeed!);
        prefs.setString('weatherCode', weatherCode!);
        prefs.setString('latitude', latitude!.toStringAsFixed(2));
        prefs.setString('longitude', longitude!.toStringAsFixed(2));
        prefs.setString('requestUrl', requestUrl!);
        prefs.setString('lastUpdated', lastUpdated!);
      } else {
        await loadCache(error: "Failed to fetch weather.");
      }
    } catch (e) {
      await loadCache(error: "Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadCache({String? error}) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTemp = prefs.getString('temperature');
    if (cachedTemp != null) {
      setState(() {
        temperature = prefs.getString('temperature');
        windSpeed = prefs.getString('windSpeed');
        weatherCode = prefs.getString('weatherCode');
        latitude = double.tryParse(prefs.getString('latitude') ?? '');
        longitude = double.tryParse(prefs.getString('longitude') ?? '');
        requestUrl = prefs.getString('requestUrl');
        lastUpdated = prefs.getString('lastUpdated');
        isCached = true;
        errorMessage = error;
      });
    } else {
      setState(() {
        errorMessage = error ?? "No cached data available.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personalized Weather Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _indexController,
              decoration: const InputDecoration(
                  labelText: "Student Index",
                  border: OutlineInputBorder(),
                  hintText: "Enter your index"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : fetchWeather,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: Colors.white))
                  : const Text("Fetch Weather"),
            ),
            const SizedBox(height: 16),
            if (latitude != null && longitude != null)
              Text(
                  "Latitude: ${latitude!.toStringAsFixed(2)}, Longitude: ${longitude!.toStringAsFixed(2)}"),
            if (requestUrl != null)
              Text("Request URL: $requestUrl",
                  style: const TextStyle(fontSize: 10)),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            if (temperature != null && windSpeed != null && weatherCode != null)
              Card(
                margin: const EdgeInsets.only(top: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Temperature: $temperature °C",
                          style: const TextStyle(fontSize: 18)),
                      Text("Wind Speed: $windSpeed km/h",
                          style: const TextStyle(fontSize: 18)),
                      Text("Weather Code: $weatherCode",
                          style: const TextStyle(fontSize: 18)),
                      Text(
                          "Last Updated: $lastUpdated ${isCached ? "(cached)" : ""}",
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
