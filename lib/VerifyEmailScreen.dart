import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // 1. Check if verified immediately on load
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      // 2. Send the email automatically when this screen opens
      sendVerificationEmail();

      // 3. Start a timer to check the status every 3 seconds
      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Important: Stop the timer when leaving the screen
    super.dispose();
  }

  // Reloads the user from Firebase to see if they clicked the link
  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      if (mounted) {
        // ✅ Success! Go to Home
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Verify your email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'A verification link has been sent to your Gmail. Please click it to activate your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: sendVerificationEmail,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Resend Email", style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushReplacementNamed(context, '/login');
                }),
                child: const Text("Cancel / Back to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}