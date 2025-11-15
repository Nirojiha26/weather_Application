🌤️ Animated Weather App
Index Number: 224130C

A Flutter-based mobile application that displays real-time weather information with a modern user interface and animated weather effects such as sun, clouds, and rain.
This project was developed as part of the Mobile Application Development assignment.

📌 Overview

This Weather App fetches live weather data using a weather API and visualizes it using beautiful animated components.
The app is designed with a clean layout, smooth transitions, and accurate weather details such as:

Temperature

Weather condition

Location

Animated weather visuals (sun, cloud, rain)

✨ Features

🌞 Sun animation (rotation & glow)

☁️ Cloud animation (floating clouds)

🌧️ Rain animation (falling droplets)

🌡️ Real-time weather data from OpenWeather API

📍 Location-based weather fetching

📱 Fully responsive UI for all screen sizes

🎨 Clean and modern interface

⚙️ Organized Flutter project structure for beginners

📂 Project Structure
lib/
 ├── main.dart
 ├── screens/
 │     └── home_screen.dart
 ├── services/
 │     └── weather_service.dart
 ├── widgets/
 │     ├── sun_animation.dart
 │     ├── cloud_animation.dart
 │     ├── rain_animation.dart
 │     └── weather_card.dart
assets/
 ├── sun.png
 ├── clouds.png
 └── rain.png
pubspec.yaml
README.md

🛠️ Technology Stack
Technology	Purpose
Flutter	UI framework
Dart	Programming language
OpenWeatherMap API	Real-time weather data
Lottie / Flutter Animations	Weather animations
Android Emulator / Device	Running the app
🚀 How to Run This Project
1️⃣ Install Flutter

Download Flutter SDK from:
https://flutter.dev/docs/get-started/install

Verify installation:

flutter --version

2️⃣ Clone the Repository
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>

3️⃣ Install Dependencies
flutter pub get

4️⃣ Run the App
flutter run


Make sure an Android Emulator or a real device is connected.