import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import Firebase Core
import 'firebase_options.dart'; // 2. Import the file you just generated
import 'core/auth_wrapper.dart';

void main() async {
  // 3. Ensure Flutter is ready before initializing Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Initialize Firebase with your project's specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const JehaApp());
}

class JehaApp extends StatelessWidget {
  const JehaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Optional: Removes the "debug" banner
      title: 'Jeha',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Optional: Gives a more modern look
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // AuthWrapper will now correctly switch between Login and Home
      home: const AuthWrapper(), 
    );
  }
}