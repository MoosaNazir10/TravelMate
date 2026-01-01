import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

class AuthService {
  // Use a private instance for non-static methods
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Static instance for static methods if needed
  static final FirebaseAuth _staticAuth = FirebaseAuth.instance;

  // --- Initialize Firebase ---
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // --- Auth State Stream ---
  // Useful for the Splash screen to check if a user is already logged in
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Get Current User ---
  // This allows ProfileScreen to access user details like email/display name
  User? get currentUser => _auth.currentUser;

  // --- Email/Password Signup ---
  Future<User?> signUp({required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An error occurred during sign up";
    }
  }

  // --- Email/Password Login ---
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An error occurred during login";
    }
  }

  // --- Google Sign In ---
  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _staticAuth.signInWithCredential(credential);
      return true;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return false;
    }
  }

  // --- Reset Password ---
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Could not send reset email";
    }
  }

  // --- Sign Out ---
  // This handles both Firebase and Google sign out to ensure a clean exit
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut(); // Signs out of Google account
      await _auth.signOut();          // Signs out of Firebase
    } catch (e) {
      throw "Error signing out: $e";
    }
  }
  Future<void> sendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw "Error sending email: $e";
    }
  }
}