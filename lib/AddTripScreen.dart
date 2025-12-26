import 'package:flutter/material.dart';
import 'package:travelmate/services/firebase_service.dart'; // Import the service
import 'trips_models.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FirebaseService _firebaseService =
      FirebaseService(); // Service instance

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

  // ✅ UPDATED METHOD TO SAVE TO FIREBASE
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
        // Prepare the data for Firestore
        final tripData = {
          'name': nameController.text,
          'location': locationController.text,
          'time': selectedTime,
          // Firestore handles DateTime objects automatically
          'description': descriptionController.text,
        };

        // Save using FirebaseService
        await _firebaseService.addTrip(tripData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip saved successfully! ✓'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Return to the previous screen
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
                      "Location",
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

                    // Save button with loading state
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
