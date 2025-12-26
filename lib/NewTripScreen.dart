import 'package:flutter/material.dart';
import 'trips_models.dart';
import 'AddTripScreen.dart'; // We'll create this for the form

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  List<Trip> trips = [];

  void _addTrip(Trip trip) {
    setState(() {
      trips.insert(0, trip);
    });
  }

  void _deleteTrip(String id) {
    setState(() {
      trips.removeWhere((trip) => trip.id == id);
    });
  }

  Future<void> _navigateToAddTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTripScreen(),
      ),
    );

    if (result != null && result is Trip) {
      _addTrip(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: Colors.white.withOpacity(0.7)),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.green),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              "My Trips",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Your saved trips",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors. black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Trips List
                Expanded(
                  child: trips.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: trips. length,
                    itemBuilder:  (context, index) {
                      return _buildTripCard(trips[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button to Add Trip
      floatingActionButton: FloatingActionButton. extended(
        onPressed: _navigateToAddTrip,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add New Trip",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flight_takeoff,
              size:  64,
              color: Colors.black26,
            ),
            const SizedBox(height: 16),
            const Text(
              "No trips yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors. black54,
              ),
            ),
            const SizedBox(height:  8),
            const Text(
              "Add your first trip to start planning",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black38,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton. icon(
              onPressed: _navigateToAddTrip,
              icon: const Icon(Icons. add, color: Colors.white),
              label: const Text(
                "Create Trip",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors. green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:  [
          BoxShadow(
            color: Colors.black. withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      // Header
      Row(
      children:  [
      Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green. shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.flight_takeoff,
        color:  Colors.green.shade600,
        size: 24,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    trip.name,
    style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    Row(
    children: [
    const Icon(Icons.location_on, size: 16, color: Colors.black54),
    const SizedBox(width: 4),
    Expanded(
    child: Text(
    trip.location,
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey. shade600,
    ),
    overflow: TextOverflow. ellipsis,
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    IconButton(
    icon: const Icon(Icons.delete, color: Colors.red),
    onPressed: () => _deleteTrip(trip.id),
    ),
    ],
    ),

    if (trip.time != null) ...[
    const SizedBox(height: 12),
    Row(
    children: [
    const Icon(Icons.calendar_today, size: 16, color:  Colors.black38),
    const SizedBox(width: 8),
    Text(
    "${trip.time!.month}/${trip.time!.day}/${trip.time!.year} ${trip.time!.hour}:${trip.time!.minute.toString().padLeft(2, '0')}",
    style: const TextStyle(
    fontSize:  14,
    color: Colors. black87,
    ),
    ),
    ],
    ),
    ],

    if (trip.description. isNotEmpty) ...[
    const SizedBox(height: 12),
    Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.grey.shade50,
    borderRadius: BorderRadius.circular(8),
    ),
    child:  Text(
    trip.description,
    style: const TextStyle(
    fontSize: 14,
    color: Colors.black87,
    ),
    ),
    ),
    ],
    ],
    ),
    );
  }
}