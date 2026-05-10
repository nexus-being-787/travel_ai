import 'package:flutter/material.dart';
import 'theme.dart';
import 'data_model.dart';
import 'widgets.dart'; // For Bounceable
import 'trip_details.dart'; // We are creating this next!

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  @override
  Widget build(BuildContext context) {
    final trips = TripRepository.myTrips;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Wallet"),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      body: trips.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return _buildTicketCard(trip);
              },
            ),
    );
  }

  Widget _buildTicketCard(Trip trip) {
    bool isUpcoming = trip.status == "Upcoming";
    IconData typeIcon = _getIcon(trip.type);

    return Bounceable(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: trip))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 180,
        child: ClipPath(
          clipper: TicketClipper(),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUpcoming
                    ? [const Color(0xFF232526), const Color(0xFF414345)] // Premium Metal Gradient
                    : [const Color(0xFF141414), const Color(0xFF141414)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                      child: Icon(typeIcon, color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(trip.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Text("\$${trip.price.toInt()}", style: const TextStyle(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                
                const Spacer(),
                // Dashed Divider
                Row(children: List.generate(30, (i) => Expanded(child: Container(color: i % 2 == 0 ? Colors.transparent : Colors.white24, height: 1)))),
                const Spacer(),

                // Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text(trip.date, style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: isUpcoming ? AppColors.accent : Colors.white10, borderRadius: BorderRadius.circular(20)),
                      child: Text(isUpcoming ? "View QR" : "Receipt", style: TextStyle(color: isUpcoming ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Bus': return Icons.directions_bus;
      case 'Train': return Icons.train;
      case 'Hotel': return Icons.hotel;
      case 'Flight': return Icons.flight;
      default: return Icons.confirmation_num;
    }
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No upcoming trips", style: TextStyle(color: Colors.white54)));
  }
}

// Visual clipper for the "Ticket" shape
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    // Left Punch Hole
    path.addOval(Rect.fromCircle(center: Offset(0.0, size.height / 1.5), radius: 10.0));
    // Right Punch Hole
    path.addOval(Rect.fromCircle(center: Offset(size.width, size.height / 1.5), radius: 10.0));
    path.fillType = PathFillType.evenOdd;
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}