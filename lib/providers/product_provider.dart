import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  static final ProductProvider _instance = ProductProvider._internal();
  factory ProductProvider() => _instance;
  
  ProductProvider._internal() : super('products');

  List<Product> get products => getAllForCurrentUser();

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return get(id);
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  // Search products by name
  List<Product> searchProducts(String query) {
    return products.where((product) => 
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      product.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get products sorted by price
  List<Product> getProductsSortedByPrice({bool ascending = true}) {
    final sortedProducts = List<Product>.from(products);
    sortedProducts.sort((a, b) => 
      ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price)
    );
    return sortedProducts;
  }

  // Get products in price range
  List<Product> getProductsInPriceRange(double minPrice, double maxPrice) {
    return products.where((product) => 
      product.price >= minPrice && product.price <= maxPrice
    ).toList();
  }

  Future<void> addProduct(Product product) async {
    try {
      print('Adding product: $product');
      await put(product.id, product);
      print('Product added successfully');
      print('Current products: ${products.length}');
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final existingProduct = getProductById(product.id);
      if (existingProduct == null) {
        throw Exception('Product not found');
      }
      await put(product.id, product);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final existingProduct = getProductById(productId);
      if (existingProduct == null) {
        throw Exception('Product not found');
      }
      await delete(productId);
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Batch operations
  Future<void> addMultipleProducts(List<Product> products) async {
    try {
      for (final product in products) {
        await put(product.id, product);
      }
    } catch (e) {
      print('Error adding multiple products: $e');
      rethrow;
    }
  }

  Future<void> deleteMultipleProducts(List<String> productIds) async {
    try {
      for (final id in productIds) {
        await delete(id);
      }
    } catch (e) {
      print('Error deleting multiple products: $e');
      rethrow;
    }
  }

  @override
  Future<void> initialize() async {
    try {
      await super.initialize();
      print('ProductProvider initialized');
      print('Current products: ${products.length}');
    } catch (e) {
      print('Error initializing ProductProvider: $e');
      rethrow;
    }
  }

  // Debug method to print all products
  void printAllProducts() {
    print('=== All Products ===');
    final allProducts = products;
    if (allProducts.isEmpty) {
      print('No products found');
    } else {
      for (var product in allProducts) {
        print('Product: ${product.toString()}');
      }
    }
    print('==================');
  }
} 