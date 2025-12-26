import 'package:flutter/material.dart';

class Trip {
  final String id;
  final String name;
  final String location;
  final DateTime?  time;
  final String description;

  Trip({
    required this. id,
    required this.name,
    required this.location,
    this.time,
    required this.description,
  });
}