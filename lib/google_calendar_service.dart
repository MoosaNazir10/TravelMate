import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarScope,
      calendar.CalendarApi.calendarEventsScope,
    ],
  );

  static GoogleSignInAccount? _currentUser;
  static calendar.CalendarApi? _calendarApi;

  // Check if user is signed in
  static bool get isSignedIn => _currentUser != null;

  // Get current user email
  static String? get userEmail => _currentUser?.email;

  // Sign in to Google
  static Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return false;
      }

      _currentUser = account;

      // Get auth headers
      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);

      // Initialize Calendar API
      _calendarApi = calendar.CalendarApi(authenticateClient);

      return true;
    } catch (error) {
      print('Error signing in: $error');
      return false;
    }
  }

  // Sign out from Google
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _calendarApi = null;
  }

  // Create a calendar event
  static Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String?  location,
  }) async {
    if (_calendarApi == null) {
      print('Calendar API not initialized');
      return false;
    }

    try {
      // Create EventDateTime objects separately
      final startEventDateTime = calendar.EventDateTime(
        dateTime: startDate,
        timeZone: 'UTC',
      );

      final endEventDateTime = calendar.EventDateTime(
        dateTime: endDate,
        timeZone: 'UTC',
      );

      // Create the event
      final event = calendar. Event(
        summary: title,
        description: description,
        location: location ?? '',
        start:  startEventDateTime,
        end:  endEventDateTime,
      );

      await _calendarApi!.events. insert(event, 'primary');
      print('Event created successfully:  $title');
      return true;
    } catch (error) {
      print('Error creating event: $error');
      return false;
    }
  }

  // Get upcoming events
  static Future<List<calendar.Event>> getUpcomingEvents({int maxResults = 10}) async {
    if (_calendarApi == null) {
      print('Calendar API not initialized');
      return [];
    }

    try {
      final now = DateTime.now();
      final events = await _calendarApi! .events.list(
        'primary',
        timeMin: now,
        maxResults: maxResults,
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items ??  [];
    } catch (error) {
      print('Error fetching events: $error');
      return [];
    }
  }

  // Delete an event
  static Future<bool> deleteEvent(String eventId) async {
    if (_calendarApi == null) {
      print('Calendar API not initialized');
      return false;
    }

    try {
      await _calendarApi!.events.delete('primary', eventId);
      print('Event deleted successfully');
      return true;
    } catch (error) {
      print('Error deleting event: $error');
      return false;
    }
  }
}

// Custom HTTP client for Google Auth
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request.. headers. addAll(_headers));
  }

  @override
  void close() {
    _client.close();
  }
}