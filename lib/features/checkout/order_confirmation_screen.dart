import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Phone with checkmark illustration
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative elements
                    Positioned(
                      top: 20,
                      right: 60,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9775FA).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 40,
                      child: Icon(
                        Icons.local_offer,
                        color: const Color(0xFF9775FA).withOpacity(0.3),
                        size: 25,
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 40,
                      child: Icon(
                        Icons.local_offer,
                        color: const Color(0xFF9775FA).withOpacity(0.3),
                        size: 20,
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      right: 50,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9775FA).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Phone mockup
                    Container(
                      width: 180,
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFF1D1E20), width: 8),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          // Notch
                          Container(
                            width: 80,
                            height: 25,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D1E20),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          const Spacer(),
                          // Checkmark
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9775FA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                
                // Title
                const Text(
                  'Order Confirmed!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Subtitle
                const Text(
                  'Your order has been confirmed, we will send\nyou confirmation email shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8F959E),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Go to Orders button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to orders screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      // TODO: Navigate to orders screen
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE7EAEF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Go to Orders',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D1E20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Continue Shopping button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9775FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
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