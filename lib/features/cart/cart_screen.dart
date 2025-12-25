import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState(); // This must match the class below
}

class _CartScreenState extends State<CartScreen> { // Renamed from _HealthyCartState
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dbService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          // Calculate Subtotal
          double subtotal = 0;
          for (var item in cartItems) {
            // Ensure price is treated as a double
            double price = double.tryParse(item['price'].toString()) ?? 0.0;
            subtotal += price * (item['quantity'] ?? 1);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      leading: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(item['title']),
                      subtitle: Text("\$${item['price']} x ${item['quantity']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _dbService.updateCartQuantity(item['id'].toString(), (item['quantity'] ?? 1) - 1),
                          ),
                          Text("${item['quantity'] ?? 1}"),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _dbService.updateCartQuantity(item['id'].toString(), (item['quantity'] ?? 1) + 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // --- Checkout Summary Box ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Subtotal:", style: TextStyle(fontSize: 16)),
                        Text("\$${subtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _dbService.clearCart();
                          // Navigate to Success Screen
                          Navigator.pushReplacementNamed(context, '/checkout-success');
                        },
                        child: const Text("Checkout"),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}