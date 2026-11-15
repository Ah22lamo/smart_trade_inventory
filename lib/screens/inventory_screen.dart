import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المخزون والتقارير')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.products.isEmpty) {
            Future.microtask(() => provider.loadProducts());
            return const Center(child: Text('لا توجد أصناف في المخزون'));
          }
          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2, color: Colors.purple),
                  title: Text(product.name),
                  subtitle: Text('الكمية: ${product.totalQuantity} | السعر: ${product.salePrice}'),
                  trailing: product.totalQuantity < 5 
                    ? const Icon(Icons.warning, color: Colors.red) 
                    : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show Reports Dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('التقارير'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _reportItem(context, 'تقرير الأرباح'),
                  _reportItem(context, 'تقرير الديون'),
                  _reportItem(context, 'الأصناف الأكثر مبيعًا'),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.bar_chart),
      ),
    );
  }

  Widget _reportItem(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      onTap: () => Navigator.pop(context),
    );
  }
}
