# 🌍 Travel AI

> **Your personal journey architect.** An AI-powered, multi-user mobile application built on Flutter and Supabase designed to plan, optimize, and secure global travel experiences.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Kotlin-%237F52FF.svg?style=for-the-badge&logo=kotlin&logoColor=white" alt="Kotlin" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
</p>

---

# 🌟 Key Features & Ecosystem

## 🤖 Generative AI Travel Planner

- **Dynamic Itineraries:** Powered by Google Gemini AI to generate complete day-by-day travel plans.
- **Intelligent Data Parsing:** Converts AI-generated responses into structured, map-ready geolocation data.
- **Instant Cloud Sync:** Save itineraries directly to the backend with one tap.

---

## 💳 Optimized Smart Wallet

- **Image Caching Engine:** Uses asynchronous image caching from the Unsplash API.
- **Live Weather Integration:** Displays current weather information using the OpenWeather API.
- **Smooth Animations:** Hero transitions provide seamless navigation between pages.

---

## 🔐 Biometric Document Vault

- **Fingerprint & Face ID Authentication** using `local_auth`.
- **Secure Local Storage** for boarding passes, hotel bookings, and travel documents.
- **Glassmorphism UI** for a modern authentication experience.

---

## 👤 Cloud-Authenticated Multi-Tenant System

- **Supabase Authentication** with UUID-based user accounts.
- **Per-user Database Isolation** so every user only accesses their own trips.
- **Offline Handling** with graceful recovery during network interruptions.

---

# 🏗 System Architecture

```text
lib/
│
├── main.dart                 # Application root & backend initialization
├── theme.dart                # Global theme & color definitions
├── widgets.dart              # Shared reusable widgets
│
└── dashboards/
    ├── login_page.dart
    ├── main_screen.dart
    ├── smart_wallet.dart
    ├── vault_screen.dart
    ├── ai_planner.dart
    ├── gemini_service.dart
    ├── weather_service.dart
    └── unsplash_service.dart

---

🗄 Database Schema

The application uses Supabase PostgreSQL.

Table: "trips"

Column| Type| Constraints| Description
id| bigint| Primary Key| Trip ID
created_at| timestamp| Default now()| Creation timestamp
title| text| NOT NULL| Destination name
subtitle| text| NOT NULL| Region or country
price| numeric| Default 0.0| Estimated trip cost
status| text| Default 'Planned'| Planned / Upcoming / Completed
type| text| NOT NULL| Adventure, Leisure, Business, etc.
date| text| Default 'Upcoming'| Travel schedule
user_id| uuid| References auth.users(id)| Owner of the trip

---

📦 Dependencies

dependencies:
  flutter:
    sdk: flutter

  supabase_flutter: ^2.12.0
  local_auth: ^2.1.8
  cached_network_image: ^3.3.1
  bounceable: ^1.0.0
  http: ^1.2.0
  flutter_map: ^6.0.0
  latlong2: ^0.9.0
  speech_to_text: ^7.0.0

---

🚀 Installation

1. Clone the Repository

git clone https://github.com/yourusername/travel_ai.git
cd travel_ai

---

2. Install Dependencies

flutter pub get

---

3. Configure Android Biometric Authentication

Replace your "MainActivity.kt" with:

package com.example.travel_ai

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {}

---

4. Configure Environment Variables

Update the following files with your own API credentials:

- "main.dart"
- "weather_service.dart"
- "unsplash_service.dart"

Required API Keys:

- Supabase URL
- Supabase Anon Key
- Google Gemini API Key
- OpenWeather API Key
- Unsplash Access Key

---

5. Run the Application

flutter run

---

📱 Tech Stack

- Flutter
- Dart
- Kotlin
- Supabase
- PostgreSQL
- Google Gemini API
- OpenWeather API
- Unsplash API
- Flutter Map
- Local Authentication

---

📸 Screens

🏠 Login
🧭 Dashboard
🤖 AI Planner
🌦 Weather
💳 Smart Wallet
🔐 Secure Vault
👤 User Profile

---

🔮 Future Enhancements

- AI Budget Prediction
- Flight Price Forecasting
- Offline Trip Planning
- Voice-Based AI Assistant
- QR Boarding Pass Generator
- Travel Expense Analytics
- Smart Currency Converter
- Group Trip Collaboration
- AI Hotel Recommendations

---

<p align="center">
  <b>🌍 Travel Smarter • Plan Faster • Explore Further ✈️</b>
</p>
```