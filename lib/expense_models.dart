import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final String currency;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.currency,
  });

  // Convert Firestore Document to Expense Object
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      currency: data['currency'] ?? 'PKR',
    );
  }
}

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Accommodation {
  final String id;
  final String type;
  final String name;
  final String address;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String bookingLink;
  final String notes;

  Accommodation({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    this.checkIn,
    this.checkOut,
    required this.bookingLink,
    required this.notes,
  });

  // Convert Firestore Document to Accommodation Object
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
    );
  }
}

class Trip {
  final String id;
  final String name;
  final String location;
  final DateTime time;
  final String description;
  final String destination;

  Trip({
    required this.id,
    required this.name,
    required this.location,
    required this.time,
    required this.description,
    required this.destination,
  });

  // Convert Firestore Document to Trip Object
  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      destination: data['destination'] ?? data['location'] ?? 'Unknown', // Fallback check
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
      description: data['description'] ?? '',
    );
  }

  double? get latitude => null;

  double? get longitude => null;
}
