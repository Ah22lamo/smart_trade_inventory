import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  Future<void> _importExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      final provider = Provider.of<AppProvider>(context, listen: false);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) { // Skip header
          if (row[0] == null) continue;
          
          final product = Product(
            code: row[0]?.value.toString() ?? '',
            name: row[1]?.value.toString() ?? '',
            quantity: double.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
            packQuantity: double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
            totalQuantity: double.tryParse(row[4]?.value.toString() ?? '0') ?? 0,
            costPrice: double.tryParse(row[5]?.value.toString() ?? '0') ?? 0,
            salePrice: 0, // Default
            packPrice: double.tryParse(row[7]?.value.toString() ?? '0') ?? 0,
            supplier: 'مورد خارجي',
            lastPurchaseDate: DateTime.now().toString(),
          );
          
          await provider.addProduct(product);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم استيراد البيانات بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المشتريات')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _importExcel,
              icon: const Icon(Icons.file_upload),
              label: const Text('استيراد فاتورة من Excel'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 20),
            const Text('أو إضافة صنف يدويًا (قيد التطوير)'),
          ],
        ),
      ),
    );
  }
}
