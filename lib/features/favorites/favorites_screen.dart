import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize the Database Service
    final DatabaseService _dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      // 2. Use StreamBuilder to listen to real-time updates from Firestore
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dbService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final favorites = snapshot.data ?? [];

          return favorites.isEmpty
              ? const Center(
                  child: Text('No favorites yet.'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
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
    );
  }
}

class FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final DatabaseService dbService; // Pass service to handle actions

  const FavoriteCard({
    super.key,
    required this.product,
    required this.dbService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                product['image'] ?? 'https://via.placeholder.com/150', // Match Firestore key
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product['price']}", // Format price from Firestore
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        // 3. Remove from favorites logic
                        dbService.removeFromFavorites(product['id'].toString());
                      },
                      iconSize: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 4. Add to cart logic
                        dbService.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to Cart!'), duration: Duration(seconds: 1)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
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