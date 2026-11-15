import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'purchases_screen.dart';
import 'sales_screen.dart';
import 'inventory_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام التجارة والمخزون'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(Icons.store, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'اسم المتجر التجاري',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuCard(context, 'البحث', Icons.search, Colors.orange, const SearchScreen()),
                _buildMenuCard(context, 'المشتريات', Icons.shopping_cart, Colors.green, const PurchasesScreen()),
                _buildMenuCard(context, 'المبيعات', Icons.sell, Colors.blue, const SalesScreen()),
                _buildMenuCard(context, 'المخزون', Icons.inventory, Colors.purple, const InventoryScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
