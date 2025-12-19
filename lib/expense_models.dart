import 'package:flutter/material.dart';

// Accommodation Model
class Accommodation {
  final String id;
  final String type; // Hotel or Airbnb
  final String name;
  final String address;
  final DateTime checkIn;
  final DateTime checkOut;
  final String bookingLink;
  final String notes;

  Accommodation({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    required this.checkIn,
    required this.checkOut,
    required this.bookingLink,
    required this.notes,
  });
}

// Expense Model
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
}

// Expense Category Model
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
