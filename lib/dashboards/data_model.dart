import 'package:flutter/material.dart';

// --- TRIP & ITINERARY MODELS (For Wallet) ---
class Activity {
  final String time;
  final String title;
  final String description;
  final IconData icon;
  final String status; // "Done", "Active", "Pending"

  Activity({required this.time, required this.title, required this.description, required this.icon, required this.status});
}

class Trip {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final String status;
  final double price;
  final String type;
  final List<Activity> itinerary;
  
  // Future fields
  final String weatherCode;
  final String currencyCode;
  final String localTimeOffset;

  Trip({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.price,
    required this.type,
    this.itinerary = const [],
    this.weatherCode = "sunny",
    this.currencyCode = "USD",
    this.localTimeOffset = "+0",
  });
}

class TripRepository {
  static List<Trip> myTrips = [
    Trip(
      id: "T-8842",
      title: "Trip to Tokyo",
      subtitle: "First Class • 1 Adult",
      date: "Nov 15, 2025",
      status: "Upcoming",
      price: 2400.0,
      type: "Flight",
      currencyCode: "JPY",
      weatherCode: "rain",
      itinerary: [
        Activity(time: "10:30 AM", title: "Flight JL402", description: "Gate A12", icon: Icons.flight_takeoff, status: "Pending"),
        Activity(time: "02:00 PM", title: "Check-in", description: "Ritz Carlton", icon: Icons.hotel, status: "Pending"),
      ],
    ),
  ];

  static void addTrip(Trip trip) {
    myTrips.insert(0, trip);
  }
}

// --- DESTINATION MODELS (For Home Tab) ---
class Destination {
  final String id;
  final String name;
  final String country;
  final String imageUrl;
  final double rating;
  final String description;
  final double priceStart;

  Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.rating,
    required this.description,
    required this.priceStart,
  });
}

class DestinationRepository {
  static List<Destination> destinations = [
    Destination(
      id: "1",
      name: "Kyoto",
      country: "Japan",
      imageUrl: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80",
      rating: 4.8,
      description: "Discover ancient temples...",
      priceStart: 1200,
    ),
    Destination(
      id: "2",
      name: "Santorini",
      country: "Greece",
      imageUrl: "https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=800&q=80",
      rating: 4.9,
      description: "Famous for its whitewashed houses...",
      priceStart: 1500,
    ),
    Destination(
      id: "3",
      name: "New York",
      country: "USA",
      imageUrl: "https://images.unsplash.com/photo-1485871981535-5be84380fb88?auto=format&fit=crop&w=800&q=80",
      rating: 4.7,
      description: "The city that never sleeps...",
      priceStart: 900,
    ),
    Destination(
      id: "4",
      name: "Bali",
      country: "Indonesia",
      imageUrl: "https://images.unsplash.com/photo-1555400038-63f5ba517a47?auto=format&fit=crop&w=800&q=80",
      rating: 4.6,
      description: "Tropical paradise...",
      priceStart: 600,
    ),
  ];
}
// ... (Keep your Trip, Activity, Destination classes as they are) ...

// --- NEW USER DATA MODELS ---

class UserProfile {
  static String name = "Alex Johnson";
  static String rank = "Global Nomad";
  static int tripsTaken = 12;
  static int countriesVisited = 5;
  static double kmTraveled = 42500.0;
  static int carbonSavedKg = 120;
}

class UserPreferences {
  static bool budgetMode = false; // false = Luxury, true = Budget
  static bool prefersWindow = true;
  static List<String> dietary = ["Vegetarian"];
  static List<String> interests = ["History", "Tech", "Nature"];
  
  static void toggleInterest(String interest) {
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
  }
}