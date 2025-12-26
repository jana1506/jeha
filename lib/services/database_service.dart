import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Getter to always get the freshest User ID
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // --- FAVORITES LOGIC ---

  Future<void> addToFavorites(Map<String, dynamic> product) async {
    if (uid == null) return;
    
    try {
      await _db
          .collection('favorites')
          .doc(uid)
          .collection('items')
          .doc(product['id'].toString())
          .set({
        'id': product['id'],
        'title': product['title'],
        'price': product['price'],
        // FIX: Extract first image from Platzi's images list
        'image': product['images'] != null ? product['images'][0] : '', 
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding to favorites: $e");
    }
  }

  Future<void> removeFromFavorites(String productId) async {
    if (uid == null) return;
    await _db.collection('favorites').doc(uid).collection('items').doc(productId).delete();
  }

  Stream<bool> isFavorited(String productId) {
    if (uid == null) return Stream.value(false);
    return _db
        .collection('favorites')
        .doc(uid)
        .collection('items')
        .doc(productId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Stream<List<Map<String, dynamic>>> getFavorites() {
    if (uid == null) return Stream.value([]);
    return _db
        .collection('favorites')
        .doc(uid)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- CART LOGIC ---

  Future<void> addToCart(Map<String, dynamic> product) async {
    if (uid == null) return;
    
    try {
      await _db
          .collection('carts')
          .doc(uid)
          .collection('items')
          .doc(product['id'].toString())
          .set({
        'id': product['id'],
        'title': product['title'],
        'price': product['price'],
        // FIX: Consistently use 'image' and extract from the list
        'image': product['images'] != null ? product['images'][0] : '',
        'quantity': 1,
      });
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getCartItems() {
    if (uid == null) return Stream.value([]);
    return _db
        .collection('carts')
        .doc(uid)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> updateCartQuantity(String productId, int newQuantity) async {
    if (uid == null) return;
    if (newQuantity <= 0) {
      await removeFromCart(productId);
    } else {
      await _db
          .collection('carts')
          .doc(uid)
          .collection('items')
          .doc(productId)
          .update({'quantity': newQuantity});
    }
  }

  Future<void> removeFromCart(String productId) async {
    if (uid == null) return;
    await _db.collection('carts').doc(uid).collection('items').doc(productId).delete();
  }

  Future<void> clearCart() async {
    if (uid == null) return;
    var items = await _db.collection('carts').doc(uid).collection('items').get();
    for (var doc in items.docs) {
      await doc.reference.delete();
    }
  }

  // --- ADDRESS LOGIC (NEW) ---

  /// Save user's delivery address to Firestore
  Future<void> saveAddress(Map<String, dynamic> addressData) async {
    if (uid == null) return;
    
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .doc('primary') // Using 'primary' as doc ID for single address
          .set({
        'name': addressData['name'],
        'country': addressData['country'],
        'city': addressData['city'],
        'phone': addressData['phone'],
        'address': addressData['address'],
        'isPrimary': addressData['isPrimary'] ?? true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving address: $e");
    }
  }

  /// Get user's saved address
  Future<Map<String, dynamic>?> getAddress() async {
    if (uid == null) return null;
    
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .doc('primary')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Error getting address: $e");
      return null;
    }
  }

  /// Stream user's address for real-time updates
  Stream<Map<String, dynamic>?> getAddressStream() {
    if (uid == null) return Stream.value(null);
    
    return _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc('primary')
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }

  /// Delete user's address
  Future<void> deleteAddress() async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc('primary')
        .delete();
  }

  // --- PAYMENT METHODS LOGIC (NEW) ---

  /// Save a payment card to Firestore
  /// NOTE: We only save last 4 digits for security, NOT the full card number or CVV
  Future<void> saveCard(Map<String, dynamic> cardData) async {
    if (uid == null) return;
    
    try {
      // Extract last 4 digits from card number
      final cardNumber = cardData['number']?.toString().replaceAll(' ', '') ?? '';
      final lastFourDigits = cardNumber.length >= 4 
          ? cardNumber.substring(cardNumber.length - 4) 
          : cardNumber;

      // Generate a unique card ID
      final cardId = DateTime.now().millisecondsSinceEpoch.toString();

      await _db
          .collection('users')
          .doc(uid)
          .collection('cards')
          .doc(cardId)
          .set({
        'id': cardId,
        'type': cardData['type'], // visa, mastercard, paypal
        'owner': cardData['owner'],
        'lastFourDigits': lastFourDigits,
        'expiry': cardData['expiry'],
        'addedAt': FieldValue.serverTimestamp(),
        // SECURITY: We deliberately do NOT save full card number or CVV
      });
    } catch (e) {
      print("Error saving card: $e");
    }
  }

  /// Get all saved cards for the user
  Future<List<Map<String, dynamic>>> getCards() async {
    if (uid == null) return [];
    
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('cards')
          .orderBy('addedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error getting cards: $e");
      return [];
    }
  }

  /// Stream all saved cards for real-time updates
  Stream<List<Map<String, dynamic>>> getCardsStream() {
    if (uid == null) return Stream.value([]);
    
    return _db
        .collection('users')
        .doc(uid)
        .collection('cards')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Delete a specific card
  Future<void> deleteCard(String cardId) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('cards')
        .doc(cardId)
        .delete();
  }

  /// Save selected payment method (card ID) for checkout
  Future<void> saveSelectedPaymentMethod(String cardId) async {
    if (uid == null) return;
    
    try {
      await _db
          .collection('users')
          .doc(uid)
          .set({
        'selectedPaymentMethod': cardId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving selected payment method: $e");
    }
  }

  /// Get the selected payment method
  Future<String?> getSelectedPaymentMethod() async {
    if (uid == null) return null;
    
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['selectedPaymentMethod'];
    } catch (e) {
      print("Error getting selected payment method: $e");
      return null;
    }
  }

  // --- ORDERS LOGIC (NEW) ---

  /// Create a new order with cart items, address, and payment info
  Future<String?> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required Map<String, dynamic> addressData,
    required Map<String, dynamic> paymentData,
    required double subtotal,
    required double shipping,
    required double total,
  }) async {
    if (uid == null) return null;
    
    try {
      // Generate unique order ID
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      
      await _db
          .collection('orders')
          .doc(orderId)
          .set({
        'orderId': orderId,
        'userId': uid,
        'items': cartItems,
        'address': {
          'name': addressData['name'],
          'country': addressData['country'],
          'city': addressData['city'],
          'phone': addressData['phone'],
          'address': addressData['address'],
        },
        'payment': {
          'type': paymentData['type'],
          'lastFourDigits': paymentData['lastFourDigits'],
        },
        'pricing': {
          'subtotal': subtotal,
          'shipping': shipping,
          'total': total,
        },
        'status': 'pending', // pending, processing, shipped, delivered, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return orderId;
    } catch (e) {
      print("Error creating order: $e");
      return null;
    }
  }

  /// Get all orders for the current user
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    if (uid == null) return [];
    
    try {
      final snapshot = await _db
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error getting orders: $e");
      return [];
    }
  }

  /// Stream user's orders for real-time updates
  Stream<List<Map<String, dynamic>>> getUserOrdersStream() {
    if (uid == null) return Stream.value([]);
    
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get a specific order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    if (uid == null) return null;
    
    try {
      final doc = await _db.collection('orders').doc(orderId).get();
      
      if (doc.exists && doc.data()?['userId'] == uid) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Error getting order: $e");
      return null;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    if (uid == null) return;
    
    try {
      await _db
          .collection('orders')
          .doc(orderId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating order status: $e");
    }
  }
}