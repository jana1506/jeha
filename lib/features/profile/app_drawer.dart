import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../favorites/favorites_screen.dart';
import '../checkout/payment_screen.dart';
import '../orders/orders_screen.dart';
import '../auth/login_screen.dart';
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final DatabaseService _dbService = DatabaseService();
  int orderCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderCount();
  }

  Future<void> _loadOrderCount() async {
    final orders = await _dbService.getUserOrders();
    if (mounted) {
      setState(() {
        orderCount = orders.length;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats Icon (Top Right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bar_chart, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Navigate to stats/analytics
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // User Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF9775FA), Color(0xFF7C5CE0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // User Name
                  Text(
                    user?.displayName ?? user?.email?.split('@')[0] ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Verified Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verified Profile',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF34C759),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Orders count - Real data from Firebase
                  if (isLoading)
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      '$orderCount ${orderCount == 1 ? 'Order' : 'Orders'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Order',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrdersScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.credit_card_outlined,
                    title: 'My Cards',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite_border,
                    title: 'Wishlist',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Color(0xFFEA4335),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEA4335),
                  ),
                ),
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Color(0xFFEA4335)),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                     Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()), 
        (Route<dynamic> route) => false,);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.black,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF8F959E),
      ),
      onTap: onTap,
    );
  }
}