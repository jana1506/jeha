import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../product/product_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  // REMOVED: late Future<List<dynamic>> _productsFuture;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  // For filtering
  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadProducts() async {
    try {
      final products = await apiService.fetchProducts();
      if (mounted) {
        setState(() {
          _allProducts = products;
          _filteredProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    _filterProducts();
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final title = product['title']?.toString().toLowerCase() ?? '';
        final category = product['category']?['name']?.toString().toLowerCase() ?? '';
        
        bool matchesSearch = query.isEmpty || 
            title.contains(query) || 
            category.contains(query);
        
        bool matchesCategory = _selectedCategory == 'All' || 
            category.contains(_selectedCategory.toLowerCase());
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (scaffoldContext) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.black, size: 24),
                            onPressed: () {
                              Scaffold.of(scaffoldContext).openDrawer();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 24),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CartScreen()),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hello',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Welcome to Laza.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8F959E),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: Color(0xFF8F959E), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search...',
                              hintStyle: TextStyle(
                                color: Color(0xFF8F959E),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9775FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.mic, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF9775FA)))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Choose Category',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              if (_selectedCategory != 'All')
                                TextButton(
                                  onPressed: () => _selectCategory('All'),
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8F959E),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 45,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildCategoryChip('All'),
                              _buildCategoryChip('Clothes'),
                              _buildCategoryChip('Electronics'),
                              _buildCategoryChip('Furniture'),
                              _buildCategoryChip('Shoes'),
                              _buildCategoryChip('Others'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCategory == 'All' ? 'All Products' : _selectedCategory,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${_filteredProducts.length} items',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8F959E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _filteredProducts.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(40),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 80,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No products found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF8F959E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  return ProductCard(product: product);
                                },
                              ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
        ],
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
                setState(() => _selectedIndex = index);
                if (index == 1) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                } else if (index == 2) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                } else if (index == 3) {
                  Scaffold.of(scaffoldContext).openDrawer();
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF9775FA),
              unselectedItemColor: const Color(0xFF8F959E),
              selectedFontSize: 12,
              unselectedFontSize: 12,
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

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9775FA) : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final dynamic product;
  final DatabaseService _dbService = DatabaseService();

  ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
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
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      product['images']?[0] ?? 'https://via.placeholder.com/200',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF5F6FA),
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40, color: Color(0xFF8F959E)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StreamBuilder<bool>(
                      stream: _dbService.isFavorited(product['id'].toString()),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () {
                            if (isFav) {
                              _dbService.removeFromFavorites(product['id'].toString());
                            } else {
                              _dbService.addToFavorites(product);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : const Color(0xFF8F959E),
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? 'Product Name',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8F959E),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category']?['name'] ?? 'Nike Sportswear Club',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\$${product['price']}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}