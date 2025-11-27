import 'package:flutter/material.dart';

void main() {
  runApp(const ShoplyApp());
}

// --- DATA MODEL ---
class Product {
  final String id;
  final String title;
  final double price;
  final IconData icon;
  final Color color;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.icon,
    required this.color,
    required this.category,
    required this.description,
  });
}

// --- MAIN APP WIDGET ---
class ShoplyApp extends StatelessWidget {
  const ShoplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shoply',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const CatalogScreen(),
    );
  }
}

// --- CATALOG SCREEN (Home) ---
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // 1. Dummy Data
  final List<Product> _allProducts = [
    Product(id: '1', title: 'Wireless Headphones', price: 99.99, icon: Icons.headphones, color: Colors.blueAccent, category: 'Tech', description: 'Noise cancelling over-ear headphones with 20h battery life.'),
    Product(id: '2', title: 'Running Shoes', price: 59.99, icon: Icons.directions_run, color: Colors.orange, category: 'Fashion', description: 'Lightweight running shoes for daily jogging.'),
    Product(id: '3', title: 'Smart Watch', price: 149.50, icon: Icons.watch, color: Colors.purple, category: 'Tech', description: 'Tracks heart rate, steps, and sleep.'),
    Product(id: '4', title: 'Leather Jacket', price: 120.00, icon: Icons.checkroom, color: Colors.brown, category: 'Fashion', description: 'Genuine leather jacket, vintage style.'),
    Product(id: '5', title: 'Gaming Mouse', price: 45.00, icon: Icons.mouse, color: Colors.redAccent, category: 'Tech', description: 'RGB lighting and high DPI sensor.'),
    Product(id: '6', title: 'Coffee Maker', price: 89.99, icon: Icons.coffee, color: Colors.teal, category: 'Home', description: 'Brew the perfect cup every morning.'),
  ];

  String _selectedCategory = 'All';
  List<Product> get _filteredProducts {
    if (_selectedCategory == 'All') return _allProducts;
    return _allProducts.where((p) => p.category == _selectedCategory).toList();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoply Store', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 2. Category Filter (Horizontal List)
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              children: ['All', 'Tech', 'Fashion', 'Home'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => _selectCategory(cat),
                    backgroundColor: Colors.white,
                    selectedColor: Colors.indigo.shade100,
                    checkmarkColor: Colors.indigo,
                  ),
                );
              }).toList(),
            ),
          ),
          
          // 3. Product Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 Columns
                childAspectRatio: 3 / 4, // Card shape
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (ctx, index) {
                final product = _filteredProducts[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Hero(
                            tag: product.id, // ID for animation
                            child: Container(
                              decoration: BoxDecoration(
                                // FIX: Replaced withOpacity with withAlpha as per deprecation warning
                                color: product.color.withAlpha((255 * 0.2).round()),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              ),
                              child: Icon(product.icon, size: 60, color: product.color),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('\$${product.price}', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- DETAILS SCREEN ---
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(product.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Big Image with Hero Animation
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Hero(
              tag: product.id,
              child: Container(
                // FIX: Replaced withOpacity with withAlpha as per deprecation warning
                color: product.color.withAlpha((255 * 0.2).round()),
                child: Icon(product.icon, size: 100, color: product.color),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // The issue was here: the description text could cause an overflow.
          // We wrap the details section in an Expanded widget so it takes available space,
          // and then use SingleChildScrollView inside to allow scrolling if the content is too long.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.category.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      Text('\$${product.price}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(product.description, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
                ],
              ),
            ),
          ),
          // Removed the Spacer() as the Expanded widget now handles taking up remaining space.
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart!')),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Add to Cart', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}