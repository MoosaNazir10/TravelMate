import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmate/AddAccommodationScreen.dart';
import 'package:travelmate/services/firebase_service.dart'; // Import your Firebase service

// Place this in a shared file like accommodation_model.dart or within AccommodationListScreen.dart
class Accommodation {
  final String id;
  final String type;
  final String name;
  final String address;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String bookingLink;
  final String notes;
  final double? latitude;  // Required for Map
  final double? longitude; // Required for Map

  Accommodation({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    this.checkIn,
    this.checkOut,
    required this.bookingLink,
    required this.notes,
    this.latitude,
    this.longitude,
  });

  factory Accommodation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Accommodation(
      id: doc.id,
      type: data['type'] ?? 'hotel',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      checkIn: (data['checkIn'] as Timestamp?)?.toDate(),
      checkOut: (data['checkOut'] as Timestamp?)?.toDate(),
      bookingLink: data['bookingLink'] ?? '',
      notes: data['notes'] ?? '',
      latitude: data['latitude']?.toDouble(), // Ensures type safety
      longitude: data['longitude']?.toDouble(),
    );
  }
}

class AccommodationListScreen extends StatefulWidget {
  const AccommodationListScreen({super.key});

  @override
  State<AccommodationListScreen> createState() =>
      _AccommodationListScreenState();
}

class _AccommodationListScreenState extends State<AccommodationListScreen> {
  final FirebaseService _firebaseService =
      FirebaseService(); // Reference to your service

  Future<void> _navigateToAddScreen() async {
    // Navigate to add screen. We don't need to handle the result because
    // the StreamBuilder automatically detects the new entry in Firestore.
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAccommodationScreen()),
    );
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
                _buildHeader(),

                // Add Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToAddScreen,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Accommodation",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Accommodations List using real-time Stream
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firebaseService.getAccommodations(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error loading accommodations"),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index];
                          final accommodation = Accommodation.fromFirestore(
                            doc,
                          );
                          return _buildAccommodationCard(accommodation);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
                  "Accommodation",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage your hotel and Airbnb bookings",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
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
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hotel, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              "No accommodations yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            const Text(
              "Add your hotel or Airbnb information to get started",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccommodationCard(Accommodation accommodation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  accommodation.type == 'hotel' ? Icons.hotel : Icons.home,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accommodation.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      accommodation.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                // Call Firebase delete method
                onPressed: () =>
                    _firebaseService.deleteAccommodation(accommodation.id),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.black38),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  accommodation.address,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          if (accommodation.checkIn != null ||
              accommodation.checkOut != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (accommodation.checkIn != null)
                  Expanded(
                    child: _buildDateInfo(
                      "Check-in",
                      accommodation.checkIn!,
                      Icons.calendar_today,
                    ),
                  ),
                if (accommodation.checkIn != null &&
                    accommodation.checkOut != null)
                  const SizedBox(width: 16),
                if (accommodation.checkOut != null)
                  Expanded(
                    child: _buildDateInfo(
                      "Check-out",
                      accommodation.checkOut!,
                      Icons.access_time,
                    ),
                  ),
              ],
            ),
          ],
          if (accommodation.bookingLink.isNotEmpty) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                // Future url_launcher logic can go here
              },
              child: Row(
                children: [
                  Icon(Icons.link, size: 20, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    "View Booking",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (accommodation.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                accommodation.notes,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime dateTime, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black38),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              "${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
