import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool rememberMe = true;

  // 1. REMOVED: _isPasswordValid variable

  @override
  void initState() {
    super.initState();
    // 2. REMOVED: passwordController.addListener(_validatePassword)
  }

  // 3. REMOVED: _validatePassword() method

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == 'user-not-found') message = "No user found for that email.";
      if (e.code == 'wrong-password') message = "Wrong password provided.";
      if (e.code == 'invalid-email') message = "The email address is invalid.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    // 4. REMOVED: passwordController.removeListener(_validatePassword)
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter your data to continue',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Username', // Changed label to Email/Username for clarity
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8F959E),
                          fontSize: 15,
                        ),
                        suffixIcon: emailController.text.isNotEmpty
                            ? const Icon(Icons.check, color: Color(0xFF34C759), size: 20)
                            : null,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE7EAEF)),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE7EAEF)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9775FA), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true, // Keep this for security
                      decoration: const InputDecoration( // 5. REMOVED: suffixIcon logic
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: Color(0xFF8F959E),
                          fontSize: 15,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE7EAEF)),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE7EAEF)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9775FA), width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Color(0xFFEA4335),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Remember Me
                Row(
                  children: [
                    const Text(
                      'Remember me',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1D1E20),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: rememberMe,
                      onChanged: (value) => setState(() => rememberMe = value),
                      activeColor: const Color(0xFF34C759),
                      activeTrackColor: const Color(0xFF34C759).withOpacity(0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Terms
                const Center(
                  child: Text(
                    'By connecting your account confirm that you agree\nwith our Term and Condition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8F959E),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9775FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 100),
                
                // Sign Up Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8F959E),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1D1E20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}