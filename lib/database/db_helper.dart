import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'trade_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE,
        name TEXT,
        quantity REAL,
        packQuantity REAL,
        totalQuantity REAL,
        costPrice REAL,
        salePrice REAL,
        packPrice REAL,
        supplier TEXT,
        lastPurchaseDate TEXT,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        type TEXT,
        saleType TEXT,
        totalAmount REAL,
        profit REAL,
        customerSupplierName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceId INTEGER,
        productCode TEXT,
        productName TEXT,
        quantity REAL,
        packQuantity REAL,
        totalQuantity REAL,
        price REAL,
        totalPrice REAL,
        packPrice REAL,
        FOREIGN KEY (invoiceId) REFERENCES invoices (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        amount REAL,
        type TEXT, -- 'customer' or 'supplier'
        date TEXT
      )
    ''');
  }

  // Product Operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProductByCode(String code) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', where: 'code = ?', whereArgs: [code]);
    if (maps.isNotEmpty) return Product.fromMap(maps.first);
    return null;
  }

  Future<int> updateProductQuantity(String code, double newTotalQuantity) async {
    final db = await database;
    return await db.update('products', {'totalQuantity': newTotalQuantity}, where: 'code = ?', whereArgs: [code]);
  }

  // Invoice Operations
  Future<int> insertInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final db = await database;
    return await db.transaction((txn) async {
      int invoiceId = await txn.insert('invoices', invoice.toMap());
      for (var item in items) {
        var itemMap = item.toMap();
        itemMap['invoiceId'] = invoiceId;
        await txn.insert('invoice_items', itemMap);
        
        // Update stock
        var productMaps = await txn.query('products', where: 'code = ?', whereArgs: [item.productCode]);
        if (productMaps.isNotEmpty) {
          var product = Product.fromMap(productMaps.first);
          double newTotal;
          if (invoice.type == 'purchase') {
            newTotal = product.totalQuantity + item.totalQuantity;
          } else {
            newTotal = product.totalQuantity - item.totalQuantity;
          }
          await txn.update('products', {'totalQuantity': newTotal}, where: 'code = ?', whereArgs: [item.productCode]);
        }
      }
      return invoiceId;
    });
  }
}
