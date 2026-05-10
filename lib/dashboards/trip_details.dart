import 'package:flutter/material.dart';
import 'theme.dart';
import 'data_model.dart';
import 'widgets.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;
  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR
          SliverAppBar(
            backgroundColor: AppColors.background,
            expandedHeight: 120,
            floating: true,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(backgroundColor: AppColors.surface, child: const BackButton(color: Colors.white)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(trip.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
          ),

          // 2. QR CODE CARD (Miniaturized)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 20)],
              ),
              child: Row(
                children: [
                  Container(
                    height: 80, width: 80,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Icon(Icons.qr_code_2, color: Colors.white, size: 60)),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.id, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(trip.subtitle, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Text("Confirmed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),

          // 3. TITLE: ITINERARY
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text("Live Itinerary", style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ),
          ),

          // 4. TIMELINE LIST
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final activity = trip.itinerary[index];
                final isLast = index == trip.itinerary.length - 1;
                return _TimelineTile(activity: activity, isLast: isLast);
              },
              childCount: trip.itinerary.length,
            ),
          ),

          // 5. BOTTOM ACTIONS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Bounceable(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.share, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text("Share Itinerary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}

// --- CUSTOM TIMELINE WIDGET ---
class _TimelineTile extends StatelessWidget {
  final Activity activity;
  final bool isLast;
  const _TimelineTile({required this.activity, required this.isLast});

  @override
  Widget build(BuildContext context) {
    Color color = _getStatusColor(activity.status);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT COLUMN (Time)
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                activity.time,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          
          // MIDDLE COLUMN (Line & Dot)
          Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                height: 12, width: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(color: color, width: 2),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: Colors.white10),
                )
            ],
          ),
          
          // RIGHT COLUMN (Card)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, right: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: activity.status == 'Active' ? color.withOpacity(0.5) : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                      child: Icon(activity.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(activity.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Done': return Colors.grey;
      case 'Active': return AppColors.accent;
      default: return Colors.blueAccent;
    }
  }
}