import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelmate/services/firebase_service.dart'; // Import the service
import 'device_calendar_service.dart';

class AddAccommodationScreen extends StatefulWidget {
  const AddAccommodationScreen({super.key});

  @override
  State<AddAccommodationScreen> createState() => _AddAccommodationScreenState();
}

class _AddAccommodationScreenState extends State<AddAccommodationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _bookingLinkController = TextEditingController();
  final _notesController = TextEditingController();
  final FirebaseService _firebaseService =
      FirebaseService(); // Instance of service

  String _selectedType = 'Hotel';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _bookingLinkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(bool isCheckIn) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.green,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isCheckIn) {
            _checkInDate = selectedDateTime;
          } else {
            _checkOutDate = selectedDateTime;
          }
        });
      }
    }
  }

  // UPDATED METHOD TO SAVE TO FIREBASE
  void _saveAccommodation() async {
    if (_formKey.currentState!.validate()) {
      if (_checkInDate == null || _checkOutDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select check-in and check-out dates'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Colors.green),
          ),
        );

        // Prepare data for Firestore
        final accommodationData = {
          'type': _selectedType.toLowerCase(),
          'name': _nameController.text,
          'address': _addressController.text,
          'checkIn': _checkInDate,
          'checkOut': _checkOutDate,
          'bookingLink': _bookingLinkController.text,
          'notes': _notesController.text,
        };

        // Save to Firebase
        await _firebaseService.addAccommodation(accommodationData);

        // SYNC TO DEVICE CALENDAR
        await DeviceCalendarService.createEvent(
          title: 'Accommodation: ${_nameController.text}',
          description: 'Type: $_selectedType\nNotes: ${_notesController.text}',
          startDate: _checkInDate!,
          endDate: _checkOutDate!,
          location: _addressController.text,
        );

        // Close loading dialog and return to list
        if (mounted) {
          Navigator.pop(context); // Pop loading dialog
          Navigator.pop(context); // Return to AccommodationListScreen

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Accommodation saved and synced! ✓'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

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
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildFormContainer(dateFormat),
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
            child: Text(
              "Add Accommodation",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFormContainer(DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Type"),
            _buildTypeDropdown(),
            const SizedBox(height: 20),
            _buildLabel("Name"),
            _buildTextField(_nameController, "Enter accommodation name"),
            const SizedBox(height: 20),
            _buildLabel("Address"),
            _buildTextField(_addressController, "Enter address", maxLines: 3),
            const SizedBox(height: 20),
            _buildLabel("Check-in"),
            _buildDateTimePicker(true, dateFormat),
            const SizedBox(height: 20),
            _buildLabel("Check-out"),
            _buildDateTimePicker(false, dateFormat),
            const SizedBox(height: 20),
            _buildLabel("Booking Link"),
            _buildTextField(_bookingLinkController, "Enter booking URL"),
            const SizedBox(height: 20),
            _buildLabel("Notes"),
            _buildTextField(
              _notesController,
              "Enter any notes",
              maxLines: 3,
              required: false,
            ),
            const SizedBox(height: 30),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.green,
      ),
    ),
  );

  Widget _buildTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          items: [
            'Hotel',
            'Airbnb',
          ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (val) => setState(() => _selectedType = val!),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _buildDateTimePicker(bool isCheckIn, DateFormat dateFormat) {
    DateTime? date = isCheckIn ? _checkInDate : _checkOutDate;
    return InkWell(
      onTap: () => _selectDateTime(isCheckIn),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black38),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? 'Select date & time' : dateFormat.format(date),
              style: TextStyle(
                color: date == null ? Colors.black54 : Colors.black87,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.green, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Cancel", style: TextStyle(color: Colors.green)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveAccommodation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
