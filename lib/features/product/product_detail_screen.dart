import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final DatabaseService _db = DatabaseService();
  int _currentImageIndex = 0;
  String _selectedSize = 'M';
  bool _showFullDescription = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String productId = widget.product['id'].toString();
    final List<dynamic> images = widget.product['images'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Gallery - FIXED
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFF5F6FA),
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 60),
                          ),
                        ),
                      );
                    },
                  ),
                  // Image Indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length > 4 ? 4 : images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? const Color(0xFF9775FA)
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Thumbnail Images - FIXED: Now clickable and changes main image
            if (images.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length > 4 ? 4 : images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() => _currentImageIndex = index);
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _currentImageIndex == index
                                  ? const Color(0xFF9775FA)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFFF5F6FA),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Product Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category - From API
                  Text(
                    widget.product['category']?['name'] ?? 'Product Category',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8F959E),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title and Price - From API
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['title'] ?? 'Product Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8F959E),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        '\$${widget.product['price']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Size Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Size',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Size Guide',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8F959E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Size Buttons
                  Row(
                    children: [
                      _buildSizeButton('S'),
                      const SizedBox(width: 10),
                      _buildSizeButton('M'),
                      const SizedBox(width: 10),
                      _buildSizeButton('L'),
                      const SizedBox(width: 10),
                      _buildSizeButton('XL'),
                      const SizedBox(width: 10),
                      _buildSizeButton('2XL'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Description - From API
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.product['description'] ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8F959E),
                      height: 1.6,
                    ),
                    maxLines: _showFullDescription ? null : 3,
                    overflow: _showFullDescription ? null : TextOverflow.ellipsis,
                  ),
                  if ((widget.product['description']?.toString().length ?? 0) > 100)
                    TextButton(
                      onPressed: () => setState(() => _showFullDescription = !_showFullDescription),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _showFullDescription ? 'Read Less' : 'Read More..',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  
                  // NOTE: Reviews section removed because API doesn't provide reviews
                  // The Platzi Fake Store API only provides:
                  // - id, title, price, description, images, category
                  // It does NOT provide: reviews, ratings, sizes
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
        child: Row(
          children: [
            // Favorite Button
            StreamBuilder<bool>(
              stream: _db.isFavorited(productId),
              builder: (context, snapshot) {
                final isFavorite = snapshot.data ?? false;
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (isFavorite) {
                        _db.removeFromFavorites(productId);
                      } else {
                        _db.addToFavorites(widget.product);
                      }
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.black,
                    ),
                    iconSize: 24,
                  ),
                );
              },
            ),
            const SizedBox(width: 15),
            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await _db.addToCart(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Added to Cart"),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF34C759),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9775FA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeButton(String size) {
    final isSelected = _selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => _selectedSize = size),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9775FA) : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}