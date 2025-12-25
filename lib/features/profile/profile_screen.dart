import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../favorites/favorites_screen.dart';
import '../cart/cart_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            
            // User Email from Firebase
            Text(
              user?.email ?? 'Guest User',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // Navigation Options
            _buildProfileOption(
              icon: Icons.favorite_outline,
              title: 'My Favorites',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              ),
            ),
            _buildProfileOption(
              icon: Icons.shopping_cart_outlined,
              title: 'My Cart',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              ),
            ),
            
            const Spacer(), // Pushes logout button to the bottom
            
            const Divider(height: 40),
            
            // Improved Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // 1. Sign out from Firebase
                    await FirebaseAuth.instance.signOut();
                    
                    // 2. Navigation Reset
                    // We pop back to the start. The AuthWrapper (in main.dart) 
                    // will see the null user and show LoginScreen automatically.
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error logging out: $e")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Logout', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}