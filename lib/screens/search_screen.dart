import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Product? _foundProduct;

  void _performSearch() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final result = await provider.searchProduct(_searchController.text);
    setState(() {
      _foundProduct = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البحث عن صنف')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'رقم الصنف أو الاسم',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 20),
            if (_foundProduct != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('رقم الصنف:', _foundProduct!.code),
                      _infoRow('الاسم:', _foundProduct!.name),
                      _infoRow('الكمية المتوفرة:', _foundProduct!.totalQuantity.toString()),
                      _infoRow('السعر:', _foundProduct!.salePrice.toString()),
                      _infoRow('سعر العبوة:', _foundProduct!.packPrice.toString()),
                    ],
                  ),
                ),
              )
            else if (_searchController.text.isNotEmpty)
              const Text('لم يتم العثور على الصنف'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }
}
