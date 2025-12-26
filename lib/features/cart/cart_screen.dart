import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../checkout/address_screen.dart';
import '../checkout/payment_screen.dart';
import '../checkout/order_confirmation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseService _dbService = DatabaseService();
  
  // Store actual address and payment data
  Map<String, dynamic>? addressData;
  Map<String, dynamic>? paymentData;
  bool isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Load saved address
    final savedAddress = await _dbService.getAddress();
    
    // Load saved cards
    final savedCards = await _dbService.getCards();
    
    // Get selected payment method
    final selectedPaymentId = await _dbService.getSelectedPaymentMethod();
    Map<String, dynamic>? selectedCard;
    
    if (selectedPaymentId != null && savedCards.isNotEmpty) {
      selectedCard = savedCards.firstWhere(
        (card) => card['id'] == selectedPaymentId,
        orElse: () => savedCards.first,
      );
    } else if (savedCards.isNotEmpty) {
      selectedCard = savedCards.first;
    }

    if (mounted) {
      setState(() {
        addressData = savedAddress;
        paymentData = selectedCard;
        isLoadingUserData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAddress = addressData != null;
    final hasPayment = paymentData != null;

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
          'Cart',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dbService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || isLoadingUserData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9775FA)),
            );
          }

          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF8F959E),
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate Subtotal and Shipping
          double subtotal = 0;
          for (var item in cartItems) {
            double price = double.tryParse(item['price'].toString()) ?? 0.0;
            subtotal += price * (item['quantity'] ?? 1);
          }
          double shipping = 10.0;
          double total = subtotal + shipping;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildCartItem(item);
                  },
                ),
              ),
              // Delivery Address Section
              _buildDeliveryAddressSection(hasAddress),
              // Payment Method Section
              _buildPaymentMethodSection(hasPayment),
              // Order Info Section
              _buildOrderInfoSection(subtotal, shipping, total),
              // Checkout Button
              _buildCheckoutButton(total, hasAddress, hasPayment),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['image'] ?? '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: const Color(0xFFF5F6FA),
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Info
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
                const SizedBox(height: 4),
                Text(
                  item['category'] ?? 'Nike Sportswear',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8F959E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${item['price']}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Quantity Controls
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: () {
                    final currentQty = item['quantity'] ?? 1;
                    if (currentQty > 1) {
                      _dbService.updateCartQuantity(
                        item['id'].toString(),
                        currentQty - 1,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${item['quantity'] ?? 1}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () {
                    _dbService.updateCartQuantity(
                      item['id'].toString(),
                      (item['quantity'] ?? 1) + 1,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEA4335)),
            onPressed: () {
              _dbService.removeFromCart(item['id'].toString());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressSection(bool hasAddress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7EAEF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFFFF7043),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8F959E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasAddress 
                      ? '${addressData!['address']}, ${addressData!['city']}'
                      : 'Add delivery address',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: hasAddress ? Colors.black : const Color(0xFF8F959E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (hasAddress)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF34C759),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddressScreen()),
              );
              
              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  addressData = result;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(bool hasPayment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7EAEF)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 30,
            decoration: BoxDecoration(
              color: hasPayment ? const Color(0xFF1A1F71) : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: hasPayment
                  ? Text(
                      (paymentData!['type'] ?? 'CARD').toString().toUpperCase().substring(0, 4),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Icon(
                      Icons.credit_card,
                      size: 20,
                      color: Color(0xFF8F959E),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8F959E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPayment 
                      ? (paymentData!['type'] ?? 'Card').toString().toUpperCase()
                      : 'Add payment method',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: hasPayment ? Colors.black : const Color(0xFF8F959E),
                  ),
                ),
                if (hasPayment && paymentData!['lastFourDigits'] != null)
                  Text(
                    '**** ${paymentData!['lastFourDigits']}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8F959E),
                    ),
                  ),
              ],
            ),
          ),
          if (hasPayment)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF34C759),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentScreen()),
              );
              
              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  paymentData = result;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection(double subtotal, double shipping, double total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7EAEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Info',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildOrderInfoRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildOrderInfoRow('Shipping cost', '\$${shipping.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildOrderInfoRow(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF8F959E),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(double total, bool hasAddress, bool hasPayment) {
    final canCheckout = hasAddress && hasPayment;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          if (!canCheckout)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFEA4335),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      !hasAddress && !hasPayment
                          ? 'Please add delivery address and payment method'
                          : !hasAddress
                              ? 'Please add delivery address'
                              : 'Please add payment method',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEA4335),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: canCheckout
                  ? () async {
                      // Get cart items before clearing
                      final cartItems = await _dbService.getCartItems().first;
                      
                      // Calculate totals
                      double subtotal = 0;
                      for (var item in cartItems) {
                        double price = double.tryParse(item['price'].toString()) ?? 0.0;
                        subtotal += price * (item['quantity'] ?? 1);
                      }
                      double shipping = 10.0;
                      double orderTotal = subtotal + shipping;
                      
                      // Create order in Firebase
                      final orderId = await _dbService.createOrder(
                        cartItems: cartItems,
                        addressData: addressData!,
                        paymentData: paymentData!,
                        subtotal: subtotal,
                        shipping: shipping,
                        total: orderTotal,
                      );
                      
                      // Clear cart
                      await _dbService.clearCart();
                      
                      if (mounted && orderId != null) {
                        // Navigate to order confirmation screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderConfirmationScreen(orderId: orderId),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9775FA),
                disabledBackgroundColor: const Color(0xFFE7EAEF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: canCheckout ? Colors.white : const Color(0xFF8F959E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}