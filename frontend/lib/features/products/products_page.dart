import 'package:flutter/material.dart';
import '../../services/product_service.dart';

class ProductsPage extends StatefulWidget {
  final String categoryId;

  const ProductsPage({super.key, required this.categoryId});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<dynamic>> _products;

  @override
  void initState() {
    super.initState();
    _products = _loadProducts();
  }

  Future<List<dynamic>> _loadProducts() async {
    final response = await ProductService.getProducts(category: widget.categoryId);
    if (response['success'] == true && response['data'] != null) {
      return response['data']['docs'] as List<dynamic>;
    } else {
      throw Exception('Failed to load products: ${response['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            if (products.isEmpty) {
              return const Center(
                child: Text('No products found in this category.'),
              );
            }
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product['name'] ?? 'No name'),
                  subtitle: Text('Price: ${product['referencePrice'] ?? 'N/A'}'),
                  leading: product['image'] != null
                      ? Image.network(
                          product['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        )
                      : const Icon(Icons.image_not_supported),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No products found.'),
            );
          }
        },
      ),
    );
  }
}