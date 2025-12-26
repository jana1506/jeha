import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool rememberMe = true;
  
  // Professional Password Validation Variables
  String _passwordStrength = '';
  Color _strengthColor = Colors.transparent;
  bool _isPasswordAcceptable = false; 

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    String password = passwordController.text;

    setState(() {
      if (password.isEmpty) {
        _passwordStrength = '';
        _strengthColor = Colors.transparent;
        _isPasswordAcceptable = false;
      } else if (password.length < 6) {
        _passwordStrength = 'Too Short';
        _strengthColor = Colors.red;
        _isPasswordAcceptable = false;
      } else {
        // Complexity check
        bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
        bool hasDigits = password.contains(RegExp(r'[0-9]'));
        bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
        bool hasLowercase = password.contains(RegExp(r'[a-z]'));

        if (hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters && password.length >= 10) {
          _passwordStrength = 'Very Strong';
          _strengthColor = const Color(0xFF008000); // Dark Green
          _isPasswordAcceptable = true;
        } else if (hasUppercase && hasLowercase && hasDigits && password.length >= 8) {
          _passwordStrength = 'Strong';
          _strengthColor = const Color(0xFF34C759); // Light Green
          _isPasswordAcceptable = true;
        } else if ((hasUppercase || hasDigits) && password.length >= 6) {
          _passwordStrength = 'Medium';
          _strengthColor = Colors.orange;
          _isPasswordAcceptable = true; 
        } else {
          _passwordStrength = 'Weak';
          _strengthColor = Colors.redAccent;
          _isPasswordAcceptable = false;
        }
      }
    });
  }

  Future<void> _handleSignUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showError("All fields are required!");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError("Please enter a valid email address.");
      return;
    }

    setState(() => _isLoading = true);
    
    String? result = await _authService.signUp(email, password);
    
    if (mounted) setState(() => _isLoading = false);

    if (result == null) {
      Navigator.pop(context);
    } else {
      _showError(result);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    passwordController.removeListener(_validatePassword);
    usernameController.dispose();
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
                const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                
                // Username Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8F959E),
                          fontSize: 15,
                        ),
                        suffixIcon: usernameController.text.isNotEmpty
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
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8F959E),
                          fontSize: 15,
                        ),
                        // Dynamic Suffix Icon based on Strength Logic
                        suffixIcon: _passwordStrength.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(right: 8, top: 15),
                                child: Text(
                                  _passwordStrength,
                                  style: TextStyle(
                                    color: _strengthColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
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
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Email Address Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email Address',
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
                        suffixIcon: emailController.text.contains('@')
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
                const SizedBox(height: 80),
                
                // Sign Up Button - Disabled if password is not acceptable
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_isPasswordAcceptable) ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9775FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}