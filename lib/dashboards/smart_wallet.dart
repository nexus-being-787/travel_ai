import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptic Feedback
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 🚀 MASSIVE Performance Boost
import 'theme.dart';
import 'data_model.dart';
import 'trip_companion.dart';
import 'vault_screen.dart';
import 'unsplash_service.dart';
import 'weather_service.dart';

class SmartWalletScreen extends StatefulWidget {
  const SmartWalletScreen({super.key});

  @override
  State<SmartWalletScreen> createState() => _SmartWalletScreenState();
}

class _SmartWalletScreenState extends State<SmartWalletScreen> {
  late Future<List<Map<String, dynamic>>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  // 🔄 Native Pull-to-Refresh & Supabase Fetching
  Future<void> _fetchTrips() async {
    setState(() {
      // 🔒 USER-SPECIFIC QUERY: Uncomment the `.eq` line once Supabase Auth is active!
      // final userId = Supabase.instance.client.auth.currentUser?.id;
      
      _tripsFuture = Supabase.instance.client
          .from('trips')
          .select()
          // .eq('user_id', userId) // 👈 THIS IS HOW YOU SEPARATE DATA PER USER!
          .order('id', ascending: false) // Newest first automatically
          .timeout(const Duration(seconds: 10));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppColors.accent),
            onPressed: () {
              HapticFeedback.lightImpact(); // 📱 Tactile feel
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultScreen()));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: _fetchTrips, // Swipe down to refresh!
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _tripsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            if (snapshot.hasError) {
              return _buildEmptyState("Connection Error", Icons.wifi_off);
            }

            final dbData = snapshot.data ?? [];
            if (dbData.isEmpty) {
              return _buildEmptyState("No trips booked yet.", Icons.airplane_ticket_outlined);
            }

            List<Trip> trips = dbData.map((row) => Trip(
              id: row['id']?.toString() ?? "0",
              title: row['title'] ?? "New Trip",
              subtitle: row['subtitle'] ?? "Unknown Location",
              date: row['date'] ?? "Upcoming",
              status: row['status'] ?? "Planned",
              price: (row['price'] ?? 0).toDouble(),
              type: row['type'] ?? "Trip",
            )).toList();

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh always works
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: trips.length,
              itemBuilder: (context, index) => _SmartTicketCard(trip: trips[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return ListView( // Wrap in ListView so Pull-to-Refresh still works when empty
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Icon(icon, size: 80, color: Colors.white.withOpacity(0.1)),
        const SizedBox(height: 16),
        Center(child: Text(message, style: const TextStyle(color: Colors.white54))),
      ],
    );
  }
}

// 🧠 THE SMART TICKET WIDGET
class _SmartTicketCard extends StatefulWidget {
  final Trip trip;
  const _SmartTicketCard({required this.trip});

  @override
  State<_SmartTicketCard> createState() => _SmartTicketCardState();
}

class _SmartTicketCardState extends State<_SmartTicketCard> {
  String? _imageUrl;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _loadDynamicData();
  }

  Future<void> _loadDynamicData() async {
    String searchLocation = widget.trip.subtitle.contains(",") 
        ? widget.trip.subtitle.split(',')[0] 
        : widget.trip.title.replaceAll("Trip to ", "");

    final results = await Future.wait([
      UnsplashService.getCityPhoto(searchLocation),
      WeatherService.getWeather(searchLocation),
    ]);

    if (mounted) {
      setState(() {
        _imageUrl = results[0] as String;
        _weatherData = results[1] as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(context, MaterialPageRoute(builder: (_) => TripCompanionScreen(trip: widget.trip)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 220, 
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. CACHED HERO IMAGE (Optimization!)
              if (_imageUrl != null)
                Hero(
                  tag: 'trip_image_${widget.trip.id}', // 🎬 Seamless transition to next screen
                  child: CachedNetworkImage(
                    imageUrl: _imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.card),
                    errorWidget: (context, url, error) => Container(color: AppColors.card, child: const Icon(Icons.error, color: Colors.white24)),
                  ),
                )
              else
                Container(color: AppColors.card, child: const Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))),

              // 2. SMOOTH GRADIENTS
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.black.withOpacity(0.4)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // 3. TRIP INFO
              Positioned(
                left: 20,
                bottom: 20,
                right: 20, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.trip.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.accent, size: 14),
                        const SizedBox(width: 4),
                        Text(widget.trip.subtitle, style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),

              // 4. WEATHER BADGE (Glassmorphism)
              if (_weatherData != null && !_weatherData!['isError'])
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15), // Glass effect
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CachedNetworkImage(
                          imageUrl: _weatherData!['iconUrl'], 
                          width: 24, height: 24,
                          errorWidget: (c,e,s) => const Icon(Icons.cloud, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 6),
                        Text("${_weatherData!['temp']}°", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),

              // 5. STATUS PILL
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.trip.status == "Upcoming" ? AppColors.accent.withOpacity(0.9) : Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.trip.status.toUpperCase(), 
                    style: TextStyle(
                      color: widget.trip.status == "Upcoming" ? Colors.black : Colors.white, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}