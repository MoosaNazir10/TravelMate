import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_models.dart';
import 'AddAccommodationScreen.dart';

class AccommodationListScreen extends StatefulWidget {
  const AccommodationListScreen({super.key});

  @override
  State<AccommodationListScreen> createState() => _AccommodationListScreenState();
}

class _AccommodationListScreenState extends State<AccommodationListScreen> {
  List<Accommodation> accommodations = [];

  void _addAccommodation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAccommodationScreen(),
      ),
    );

    if (result != null && result is Accommodation) {
      setState(() {
        accommodations.add(result);
      });
    }
  }

  void _deleteAccommodation(int index) {
    setState(() {
      accommodations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // White Overlay
          Container(
            color: Colors.white.withOpacity(0.7),
          ),

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
                        child: Text(
                          "Accommodation",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                // Add Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addAccommodation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Accommodation",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // List or Empty State
                Expanded(
                  child: accommodations.isEmpty
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.hotel,
                                  size: 64,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No accommodations yet",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Add your first accommodation",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: accommodations.length,
                          itemBuilder: (context, index) {
                            return _buildAccommodationCard(
                              accommodations[index],
                              index,
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

  Widget _buildAccommodationCard(Accommodation accommodation, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon and Delete Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.hotel,
                  color: Colors.blue,
                  size: 32,
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
                      accommodation.type,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteAccommodation(index),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Address
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  accommodation.address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Check-in
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Check-in: ${dateFormat.format(accommodation.checkIn)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                timeFormat.format(accommodation.checkIn),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Check-out
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Check-out: ${dateFormat.format(accommodation.checkOut)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                timeFormat.format(accommodation.checkOut),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // Booking Link
          if (accommodation.bookingLink.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.link, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    accommodation.bookingLink,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Notes
          if (accommodation.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                accommodation.notes,
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
