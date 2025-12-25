import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_service.dart'; // Ensure path is correct

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final DatabaseService _db = DatabaseService(); // Initialize Database Service

  ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure ID is a string for Firestore paths
    final String productId = product['id'].toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Image.network(
              product['imageUrl'] ?? 'https://via.placeholder.com/400',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? 'Product Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['price'] != null ? '\$${product['price']}' : '\$0.00',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['description'] ??
                        'This is a placeholder description for the product.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Bar with Actions
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            // Favorite Button with Real-time Firestore Check
            StreamBuilder<bool>(
              stream: _db.isFavorited(productId),
              builder: (context, snapshot) {
                final isFavorite = snapshot.data ?? false;
                return IconButton(
                  onPressed: () {
                    if (isFavorite) {
                      _db.removeFromFavorites(productId);
                    } else {
                      _db.addToFavorites(product);
                    }
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  iconSize: 28,
                );
              },
            ),
            const SizedBox(width: 8),
            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await _db.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added to Cart")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}