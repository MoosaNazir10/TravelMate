import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../AccommodationListScreen.dart';
import '../expense_models.dart' hide Accommodation;

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================================================
  // ACCOMMODATION LOGIC (CRUD)
  // ==================================================

  // Add new accommodation linked to the user
  Future<void> addAccommodation(Map<String, dynamic> data) async {
    if (currentUserId == null) throw Exception("User not logged in");

    await _db.collection('users')
        .doc(currentUserId)
        .collection('accommodations')
        .add({
      ...data,
      'created_at': FieldValue.serverTimestamp(), // For ordering the list
    });
  }

  // Stream of accommodations for real-time UI updates
  Stream<QuerySnapshot> getAccommodations() {
    if (currentUserId == null) return const Stream.empty();

    return _db.collection('users')
        .doc(currentUserId)
        .collection('accommodations')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // Delete accommodation by its Firestore document ID
  Future<void> deleteAccommodation(String docId) async {
    if (currentUserId == null) return;

    await _db.collection('users')
        .doc(currentUserId)
        .collection('accommodations')
        .doc(docId)
        .delete();
  }

  // ==================================================
  // EXPENSE LOGIC (CRUD)
  // ==================================================

  // Add new expense linked to the user
  Future<void> addExpense(Map<String, dynamic> data) async {
    if (currentUserId == null) throw Exception("User not logged in");

    await _db.collection('users')
        .doc(currentUserId)
        .collection('expenses')
        .add({
      ...data,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Stream of expenses for real-time UI updates
  Stream<QuerySnapshot> getExpenses() {
    if (currentUserId == null) return const Stream.empty();

    return _db.collection('users')
        .doc(currentUserId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Delete expense by its Firestore document ID
  Future<void> deleteExpense(String docId) async {
    if (currentUserId == null) return;

    await _db.collection('users')
        .doc(currentUserId)
        .collection('expenses')
        .doc(docId)
        .delete();
  }

  // Inside FirebaseService class in firebase_service.dart

  Future<void> addTrip(Map<String, dynamic> data) async {
    if (currentUserId == null) throw Exception("User not logged in");

    await _db.collection('users')
        .doc(currentUserId)
        .collection('trips')
        .add({
      ...data,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Inside FirebaseService class in firebase_service.dart

// Save or Update Calendar Settings
  Future<void> updateCalendarSettings(Map<String, dynamic> settings) async {
    if (currentUserId == null) return;
    await _db.collection('users').doc(currentUserId).set({
      'calendarSettings': settings,
    }, SetOptions(merge: true));
  }

// Stream to listen to settings in real-time
  Stream<DocumentSnapshot> getCalendarSettings() {
    if (currentUserId == null) return const Stream.empty();
    return _db.collection('users').doc(currentUserId).snapshots();
  }

  // Inside FirebaseService class in firebase_service.dart

// Stream to get real-time exchange rates
  Stream<DocumentSnapshot> getExchangeRates() {
    // We store global exchange rates in a 'metadata' collection
    return _db.collection('metadata').doc('exchange_rates').snapshots();
  }

// Function to update rates (typically used by an admin or a cloud function)
  Future<void> updateRates(Map<String, double> newRates) async {
    await _db.collection('metadata').doc('exchange_rates').set({
      'rates': newRates,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  // Inside FirebaseService class in firebase_service.dart

// Save the user's preferred device calendar ID
  Future<void> saveSelectedCalendarId(String calendarId) async {
    if (currentUserId == null) return;
    await _db.collection('users').doc(currentUserId).set({
      'selectedCalendarId': calendarId,
    }, SetOptions(merge: true));
  }

// Fetch the saved calendar ID once at startup
  Future<String?> getSavedCalendarId() async {
    if (currentUserId == null) return null;
    var doc = await _db.collection('users').doc(currentUserId).get();
    return doc.data()?['selectedCalendarId'];
  }

  // Inside FirebaseService class in firebase_service.dart

// Fetch all trips as a Future for one-time map loading
  Future<List<Trip>> getTripsList() async {
    if (currentUserId == null) return [];
    final snapshot = await _db.collection('users').doc(currentUserId).collection('trips').get();
    return snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
  }

// Fetch all accommodations as a Future for one-time map loading
// Inside FirebaseService class in firebase_service.dart

// Fetch all accommodations as a Future for one-time map loading
// Inside FirebaseService class
  Future<List<Accommodation>> getAccommodationsList() async {
    if (currentUserId == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(currentUserId)
        .collection('accommodations')
        .get();

    return snapshot.docs.map((doc) => Accommodation.fromFirestore(doc)).toList();
  }
}