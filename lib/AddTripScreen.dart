import 'package:flutter/material.dart';
import 'package:travelmate/services/firebase_service.dart';
import 'package:travelmate/services/notification_service.dart';
import 'package:geocoding/geocoding.dart'; //

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  double? _selectedLatitude;
  double? _selectedLongitude;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  DateTime? selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // ✅ FULLY UPDATED METHOD WITH AUTOMATIC GEOCODING
  void _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      if (selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // --- STEP 1: AUTOMATICALLY GET COORDINATES FROM ADDRESS ---
        try {
          List<Location> locations = await locationFromAddress(locationController.text);
          if (locations.isNotEmpty) {
            _selectedLatitude = locations.first.latitude;
            _selectedLongitude = locations.first.longitude;
          }
        } catch (geoError) {
          debugPrint("Geocoding failed: $geoError");
          // If geocoding fails, we still continue but coordinates will be null
        }

        // --- STEP 2: PREPARE DATA ---
        final tripData = {
          'name': nameController.text,
          'location': locationController.text,
          'destination': locationController.text, // Added for model compatibility
          'time': selectedTime,
          'description': descriptionController.text,
          'latitude': _selectedLatitude,
          'longitude': _selectedLongitude,
        };

        // --- STEP 3: SAVE TO FIREBASE ---
        await _firebaseService.addTrip(tripData);

        // --- STEP 4: SCHEDULE NOTIFICATION ---
        final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await NotificationService.scheduleTripReminder(
          id: notificationId,
          title: "Upcoming Trip: ${nameController.text}",
          body: "Get ready! Your trip to ${locationController.text} starts soon.",
          scheduledDate: selectedTime!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip saved successfully! ✓'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving trip: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.7)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.green),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "New Trip",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    buildField(
                      Icons.edit,
                      "Trip Name",
                      nameController,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please enter trip name'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    buildDateTimeField(),
                    const SizedBox(height: 20),
                    buildField(
                      Icons.location_on,
                      "Location (City, Country)", // Hint for better accuracy
                      locationController,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please enter location'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    buildField(
                      Icons.description,
                      "Description",
                      descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.yellow,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Save",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.yellow,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildField(
      IconData icon,
      String hint,
      TextEditingController controller, {
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget buildDateTimeField() {
    return InkWell(
      onTap: _selectDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black38),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.green),
            const SizedBox(width: 16),
            Text(
              selectedTime != null
                  ? "${selectedTime!.month}/${selectedTime!.day}/${selectedTime!.year} ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                  : "Select Date & Time",
              style: TextStyle(
                fontSize: 16,
                color: selectedTime != null ? Colors.black87 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}