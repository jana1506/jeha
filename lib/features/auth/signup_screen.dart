import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // --- Validation Logic ---
  Future<void> _handleSignUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // 1. Check for empty fields
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError("All fields are required!");
      return;
    }

    // 2. Validate email format (basic regex)
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError("Please enter a valid email address.");
      return;
    }

    // 3. Check password length (Firebase requires at least 6 characters)
    if (password.length < 6) {
      _showError("Password must be at least 6 characters.");
      return;
    }

    // 4. Validate passwords match
    if (password != confirmPassword) {
      _showError("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);
    
    // 5. Call Firebase via AuthService
    String? result = await _authService.signUp(email, password);
    
    if (mounted) setState(() => _isLoading = false);

    if (result == null) {
      // Success: AuthWrapper will handle navigation
      Navigator.pop(context);
    } else {
      // Error: Show the Firebase error message
      _showError(result);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Create Account', 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Join the Jeha community', 
              style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email', 
                prefixIcon: Icon(Icons.email), 
                border: OutlineInputBorder()
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password', 
                prefixIcon: Icon(Icons.lock), 
                border: OutlineInputBorder()
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password', 
                prefixIcon: Icon(Icons.lock), 
                border: OutlineInputBorder()
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    ) 
                  : const Text('Sign Up', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}