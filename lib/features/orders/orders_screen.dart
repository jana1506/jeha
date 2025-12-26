import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/database_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbService.getUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9775FA)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading orders'),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF8F959E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start shopping to see your orders here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8F959E),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>? ?? [];
    final pricing = order['pricing'] as Map<String, dynamic>? ?? {};
    final status = order['status'] ?? 'pending';
    final createdAt = order['createdAt'];
    
    // Format date
    String dateStr = 'N/A';
    if (createdAt != null) {
      try {
        final date = (createdAt as dynamic).toDate();
        dateStr = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        dateStr = 'Recent';
      }
    }

    // Status color and text
    Color statusColor;
    String statusText;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFFFFA726);
        statusText = 'Pending';
        break;
      case 'processing':
        statusColor = const Color(0xFF42A5F5);
        statusText = 'Processing';
        break;
      case 'shipped':
        statusColor = const Color(0xFF9775FA);
        statusText = 'Shipped';
        break;
      case 'delivered':
        statusColor = const Color(0xFF34C759);
        statusText = 'Delivered';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEA4335);
        statusText = 'Cancelled';
        break;
      default:
        statusColor = const Color(0xFF8F959E);
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE7EAEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order['orderId']?.toString().substring(0, 8) ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8F959E),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          
          // Order Items Preview
          Text(
            '${items.length} ${items.length == 1 ? 'item' : 'items'}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8F959E),
            ),
          ),
          const SizedBox(height: 8),
          
          // Show first 2 items
          ...items.take(2).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        color: Color(0xFF8F959E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Product',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Qty: ${item['quantity'] ?? 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8F959E),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${item['price']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          if (items.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${items.length - 2} more ${items.length - 2 == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8F959E),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '\$${pricing['total']?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9775FA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}