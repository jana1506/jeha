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
}