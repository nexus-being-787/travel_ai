import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets.dart';
import 'data_model.dart';
import 'booking_flow.dart'; // To book directly

class DestinationScreen extends StatelessWidget {
  final Destination destination;
  const DestinationScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. COLLAPSING HEADER
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: BackButton(color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(destination.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(destination.imageUrl, fit: BoxFit.cover),
                  // Gradient Overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.background],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CONTENT BODY
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(destination.country, style: const TextStyle(fontSize: 18, color: Colors.white54)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(destination.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("About", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(destination.description, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                  
                  const SizedBox(height: 30),
                  const Text("Highlights", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  
                  // Horizontal Photo Strip
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (ctx, i) => Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(destination.imageUrl), // reusing image for demo
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      
      // 3. FLOATING ACTION BAR
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: AppColors.surface,
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Start from", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Text("\$${destination.priceStart.toInt()}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const Spacer(),
              Bounceable(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFlow(type: "Flight")));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(30)),
                  child: const Text("Plan Trip", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}