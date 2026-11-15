import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<InvoiceItem> _cartItems = [];
  double _totalAmount = 0;

  void _addToCart(Product product, double qty) {
    setState(() {
      _cartItems.add(InvoiceItem(
        invoiceId: 0, // Temporary
        productCode: product.code,
        productName: product.name,
        quantity: qty,
        packQuantity: 0,
        totalQuantity: qty,
        price: product.salePrice,
        totalPrice: product.salePrice * qty,
        packPrice: product.packPrice,
      ));
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _totalAmount = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _printInvoice() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('فاتورة مبيعات', style: pw.TextStyle(fontSize: 24)),
              pw.Divider(),
              pw.Table.fromTextArray(
                data: [
                  ['الصنف', 'الكمية', 'السعر', 'الإجمالي'],
                  ..._cartItems.map((item) => [item.productName, item.quantity, item.price, item.totalPrice]),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('الإجمالي: $_totalAmount'),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المبيعات')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return ListTile(
                  title: Text(item.productName),
                  subtitle: Text('الكمية: ${item.quantity} - السعر: ${item.price}'),
                  trailing: Text('${item.totalPrice}'),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي: $_totalAmount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: _cartItems.isEmpty ? null : _printInvoice,
                  child: const Text('حفظ وطباعة'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
