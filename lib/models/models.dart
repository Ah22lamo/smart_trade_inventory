class Product {
  final int? id;
  final String code;
  final String name;
  final double quantity;
  final double packQuantity;
  final double totalQuantity;
  final double costPrice;
  final double salePrice;
  final double packPrice;
  final String supplier;
  final String lastPurchaseDate;
  final String? imagePath;

  Product({
    this.id,
    required this.code,
    required this.name,
    required this.quantity,
    required this.packQuantity,
    required this.totalQuantity,
    required this.costPrice,
    required this.salePrice,
    required this.packPrice,
    required this.supplier,
    required this.lastPurchaseDate,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'quantity': quantity,
      'packQuantity': packQuantity,
      'totalQuantity': totalQuantity,
      'costPrice': costPrice,
      'salePrice': salePrice,
      'packPrice': packPrice,
      'supplier': supplier,
      'lastPurchaseDate': lastPurchaseDate,
      'imagePath': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      quantity: map['quantity'],
      packQuantity: map['packQuantity'],
      totalQuantity: map['totalQuantity'],
      costPrice: map['costPrice'],
      salePrice: map['salePrice'],
      packPrice: map['packPrice'],
      supplier: map['supplier'],
      lastPurchaseDate: map['lastPurchaseDate'],
      imagePath: map['imagePath'],
    );
  }
}

class Invoice {
  final int? id;
  final String date;
  final String type; // 'purchase' or 'sale'
  final String saleType; // 'wholesale' or 'retail'
  final double totalAmount;
  final double profit;
  final String customerSupplierName;

  Invoice({
    this.id,
    required this.date,
    required this.type,
    required this.saleType,
    required this.totalAmount,
    required this.profit,
    required this.customerSupplierName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'saleType': saleType,
      'totalAmount': totalAmount,
      'profit': profit,
      'customerSupplierName': customerSupplierName,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      date: map['date'],
      type: map['type'],
      saleType: map['saleType'],
      totalAmount: map['totalAmount'],
      profit: map['profit'],
      customerSupplierName: map['customerSupplierName'],
    );
  }
}

class InvoiceItem {
  final int? id;
  final int invoiceId;
  final String productCode;
  final String productName;
  final double quantity;
  final double packQuantity;
  final double totalQuantity;
  final double price;
  final double totalPrice;
  final double packPrice;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.packQuantity,
    required this.totalQuantity,
    required this.price,
    required this.totalPrice,
    required this.packPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'productCode': productCode,
      'productName': productName,
      'quantity': quantity,
      'packQuantity': packQuantity,
      'totalQuantity': totalQuantity,
      'price': price,
      'totalPrice': totalPrice,
      'packPrice': packPrice,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoiceId'],
      productCode: map['productCode'],
      productName: map['productName'],
      quantity: map['quantity'],
      packQuantity: map['packQuantity'],
      totalQuantity: map['totalQuantity'],
      price: map['price'],
      totalPrice: map['totalPrice'],
      packPrice: map['packPrice'],
    );
  }
}
