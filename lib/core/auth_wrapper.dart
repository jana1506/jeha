import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // This StreamBuilder is the "Watchman" of your app.
    // It detects FirebaseAuth.instance.signOut() instantly.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Error State (Check for network or Firebase issues)
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error connecting to Authentication.")),
          );
        }

        // 3. Authenticated State
        // If snapshot.hasData is true, Firebase says "I know this user."
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // 4. Unauthenticated State
        // If we reach here, no one is logged in.
        return const LoginScreen();
      },
    );
  }
}