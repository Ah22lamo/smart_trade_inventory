import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/models.dart';

class AppProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Product> _products = [];
  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await _dbHelper.getAllProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _dbHelper.insertProduct(product);
    await loadProducts();
  }

  Future<Product?> searchProduct(String query) async {
    // Search by code or name
    try {
      return _products.firstWhere(
        (p) => p.code == query || p.name.contains(query),
      );
    } catch (e) {
      return null;
    }
  }
}
