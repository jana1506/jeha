import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../home/home_screen.dart'; // Add this import
import '../cart/cart_screen.dart'; // Add this import
import '../profile/app_drawer.dart'; // Add this import

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseService _dbService = DatabaseService();
  int _selectedIndex = 1; // Default to 1 because we are on the Favorites screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(), // Added drawer to match Home
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      // Use StreamBuilder to listen to real-time updates from Firestore
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dbService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF9775FA)));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(
              child: Text('No favorites yet.', style: TextStyle(color: Color(0xFF8F959E))),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.7,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final product = favorites[index];
              return FavoriteCard(product: product, dbService: _dbService);
            },
          );
        },
      ),
      bottomNavigationBar: Builder(
        builder: (scaffoldContext) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                if (index == _selectedIndex) return; // Do nothing if already on this tab

                setState(() => _selectedIndex = index);

                if (index == 0) {
                  // Navigate to Home
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                } else if (index == 2) {
                  // Navigate to Cart
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                } else if (index == 3) {
                  // Open Drawer
                  Scaffold.of(scaffoldContext).openDrawer();
                  // Reset index back to 1 after drawer opens so "Wishlist" remains highlighted
                  setState(() => _selectedIndex = 1);
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF9775FA),
              unselectedItemColor: const Color(0xFF8F959E),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final DatabaseService dbService;

  const FavoriteCard({
    super.key,
    required this.product,
    required this.dbService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                product['image'] ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'] ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product['price']}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => dbService.removeFromFavorites(product['id'].toString()),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        dbService.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to Cart!'),
                            duration: Duration(seconds: 1),
                            backgroundColor: Color(0xFF9775FA),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9775FA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}