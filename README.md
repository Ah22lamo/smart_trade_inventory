# Smart Trade & Inventory
**تطبيق التجارة والمخزون الذكي**

An offline-first Flutter application for small retail and wholesale businesses. The app targets Arabic-speaking users and stores products, invoices, and inventory data locally with SQLite.

![Status](https://img.shields.io/badge/status-early%20prototype-orange)
![Flutter](https://img.shields.io/badge/Flutter-3.29.3-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7.2-0175C2?logo=dart)
![SQLite](https://img.shields.io/badge/storage-SQLite-003B57?logo=sqlite)

> **Status: early functional prototype — not production-ready.**
> The offline database, Arabic UI shell, inventory list, search, basic Excel import, and PDF printing shell exist.
> The sales and purchasing workflows are incomplete. See [Known flaws at a glance](#known-flaws-at-a-glance).

---

## Overview

The project explores a common small-business workflow: import a supplier invoice from Excel, keep stock quantities up to date, create sales invoices, print them as PDF, and review simple inventory alerts.

The implementation proves several pieces of that workflow, but it does not complete the chain end to end. The current repository is best understood as a **learning prototype** and a starting point for a properly engineered inventory application.

**Platform:** Android (the repository contains only an Android runner).
**Backend:** none — all data is local.
**Language:** Arabic-first UI with RTL layout.
**State management:** Provider.
**Database:** SQLite through `sqflite`.

---

## Project status

| Area | Status | Notes |
|---|---|---|
| Offline SQLite storage | Implemented | Products, invoices, invoice items, and debts tables exist |
| Arabic RTL UI shell | Implemented | `MaterialApp` uses `ar_YE` and RTL localization delegates |
| Home navigation | Implemented | Four modules: search, purchases, sales, inventory |
| Inventory list | Implemented | Lists products and shows a warning icon below quantity 5 |
| Product search | Partial | Searches only the in-memory product list; not a database query |
| Excel purchase import | Partial | Reads `.xlsx` and writes products; no invoice, validation, or preview |
| Sales workflow | UI shell only | The cart cannot be populated; printing does not save anything |
| Arabic PDF invoice | Partial / likely broken | No Arabic font is embedded; default PDF fonts lack Arabic glyphs |
| Reports | Placeholder | Dialog items only close the dialog |
| Debts | Schema only | No UI or operations use the table |
| Multi-currency | Not implemented | No currency field or exchange-rate logic exists |
| Tests | None | No `test/` directory |
| Release configuration | Incomplete | Debug signing, `com.example` application ID, default label |

---

## What works today

- The app launches and displays an Arabic home screen with four modules.
- SQLite tables are created on first launch.
- Products can be listed in the inventory screen.
- Low-stock products are visually flagged when `totalQuantity < 5`.
- A product can be searched by code or name **after** the in-memory list has been loaded.
- A `.xlsx` file can be selected and parsed with fixed column positions.
- Imported rows are written to the `products` table.
- A PDF sales invoice can be generated and sent to the platform print dialog.

## What is incomplete or non-functional

- There is no way to add a product to the sales cart. `_addToCart` exists but is never called.
- The sales screen therefore starts and stays empty; the print button is disabled.
- "Save & Print" only prints. It does not save the invoice, decrement stock, or calculate profit.
- The purchase import does not create a purchase invoice or increment stock. It **replaces** the product row.
- Imported products receive `salePrice = 0`, so they cannot be sold correctly without manual editing.
- The reports dialog has no report logic.
- The debts table has no UI.
- There is no invoice history or product edit/delete screen.
- There is no manual product entry; the screen explicitly says it is under development.
- Multi-currency support is claimed in the old README but not implemented in the schema or code.
- There is no backup, restore, export, authentication, or cloud sync.

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.29.3 |
| Language | Dart 3.7.2 |
| State management | Provider 6.1 |
| Local database | `sqflite` 2.3 + `path` |
| Excel parsing | `excel` 4.0 |
| PDF generation | `pdf` 3.10 |
| Printing | `printing` 5.11 |
| File selection | `file_picker` 8.0 |
| Formatting | `intl` 0.19 |
| Declared but currently unused | `fl_chart`, `image_picker`, `share_plus`, `path_provider` |

The project was created with Flutter 3.29.3 and analyzed with Dart 3.7.2.

---

## Architecture

```text
lib/
├── main.dart                     # App bootstrap, theme, locale, Provider
├── database/
│   └── db_helper.dart            # Singleton SQLite helper and queries
├── models/
│   └── models.dart               # Product, Invoice, InvoiceItem
├── providers/
│   └── app_provider.dart         # Product list and search state
└── screens/
    ├── home_screen.dart          # Module grid
    ├── inventory_screen.dart     # Product list, low-stock warning, report dialog
    ├── purchases_screen.dart     # Excel import
    ├── sales_screen.dart         # Cart UI and PDF printing
    └── search_screen.dart        # Product lookup
```

There is no repository layer, service layer, dependency injection, or use-case layer. Screens call `AppProvider`, and `AppProvider` calls `DBHelper` directly.

> **Repository hygiene note:** a nested `trade_app/` directory contains an identical copy of the project. It is ignored by Git and should be removed before the repository is published.

---

## Database schema

### `products`

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER | Primary key, autoincrement |
| `code` | TEXT | Unique product code |
| `name` | TEXT | Product name |
| `quantity` | REAL | Loose-unit quantity |
| `packQuantity` | REAL | Pack quantity |
| `totalQuantity` | REAL | Total stock |
| `costPrice` | REAL | Purchase cost |
| `salePrice` | REAL | Selling price |
| `packPrice` | REAL | Pack selling price |
| `supplier` | TEXT | Supplier name |
| `lastPurchaseDate` | TEXT | Stored as a string |
| `imagePath` | TEXT | Optional image path |

### `invoices`

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER | Primary key |
| `date` | TEXT | Stored as a string |
| `type` | TEXT | `purchase` or `sale` |
| `saleType` | TEXT | `wholesale` or `retail` |
| `totalAmount` | REAL | Invoice total |
| `profit` | REAL | Intended profit |
| `customerSupplierName` | TEXT | Free-text name |

### `invoice_items`

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER | Primary key |
| `invoiceId` | INTEGER | Declared foreign key to `invoices.id` |
| `productCode` | TEXT | Product reference |
| `productName` | TEXT | Snapshot of the name |
| `quantity` | REAL | Loose quantity |
| `packQuantity` | REAL | Pack quantity |
| `totalQuantity` | REAL | Total quantity |
| `price` | REAL | Unit price |
| `totalPrice` | REAL | Line total |
| `packPrice` | REAL | Pack price |

### `debts`

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER | Primary key |
| `name` | TEXT | Customer or supplier |
| `amount` | REAL | Debt amount |
| `type` | TEXT | `customer` or `supplier` |
| `date` | TEXT | Stored as a string |

**Schema issues:** there is no currency column, no customer/supplier table, no invoice number, no payment status, no indexes, no `onUpgrade` migration, and no `PRAGMA foreign_keys = ON`.

---

## How the current workflows behave

### 1. Excel purchase import

1. The user selects an `.xlsx` file.
2. The file is read **synchronously** with `readAsBytesSync()`.
3. The first row is skipped as a header.
4. Columns are read by fixed index: code, name, quantity, pack quantity, total quantity, cost price, sale price (ignored), pack price.
5. Every row becomes a `Product`.
6. `salePrice` is set to `0`.
7. `supplier` is hard-coded to `مورد خارجي`.
8. `totalQuantity` is written as-is; it does not add to existing stock.
9. `insertProduct` uses `ConflictAlgorithm.replace`, so an existing code is deleted and reinserted.

There is no preview, no validation, no duplicate review, no rollback, no purchase invoice, and no error handling for malformed files.

### 2. Sales

1. `SalesScreen` starts with an empty `_cartItems` list.
2. `_addToCart` exists but is not connected to any button or product picker.
3. The user can only see the empty cart and a disabled print button.
4. If the cart were populated, "Save & Print" would build a PDF and call `Printing.layoutPdf`.
5. The invoice is never written to the database, stock is never decremented, and profit is never calculated.

### 3. Inventory and search

- `InventoryScreen` builds the product list and calls `provider.loadProducts()` through `Future.microtask` inside `build`.
- The low-stock threshold is hard-coded to `5`.
- Tapping a report item only closes the dialog.
- `AppProvider.searchProduct` uses `firstWhere` over the in-memory `_products` list.
- Search is case-sensitive, does not trim input, and returns the first product for an empty query.
- If products have not been loaded, search returns nothing.

---

## Getting started

### Prerequisites

- Flutter 3.29.3 or a compatible 3.x SDK
- Dart 3.7.2 or a compatible SDK
- Android SDK and an emulator or physical Android device
- Java 17 (the Android module sets Java 17 compatibility)

### Run the app

```bash
flutter pub get
flutter run
```

### Analyze

```bash
flutter analyze
```

At the time of writing, analysis reports:

- unused imports in `sales_screen.dart`
- the unused `_addToCart` method
- a deprecated `Table.fromTextArray` call

The nested duplicate folder adds the same warnings a second time.

### Build

```bash
flutter build apk --debug
```

A release build is not recommended yet: the release build type still uses the debug signing configuration.

### Assets and fonts

- `assets/images/` is declared in `pubspec.yaml` but contains no committed files.
- The Cairo font is disabled in `main.dart` because `assets/fonts/` is missing.
- The PDF invoice uses the default PDF font, which does not support Arabic glyph shaping.

---

## Known flaws at a glance

1. **The sales workflow cannot be completed.** `_addToCart` is dead code; there is no product picker; the cart is always empty.
2. **"Save & Print" does not save.** It prints a PDF but never inserts the invoice, decrements stock, or calculates profit.
3. **Purchase import overwrites inventory instead of recording a purchase.** It replaces products by code, does not increment stock, and stores `salePrice = 0`.
4. **Excel import has no validation or recovery.** It assumes fixed column order, reads the file synchronously on the UI thread, and has no preview, duplicate review, or rollback.
5. **The reports screen is a placeholder.** Every report item simply closes the dialog.
6. **Multi-currency is not implemented.** There is no currency column, no exchange rate, and no per-invoice currency.
7. **The debts table is unused.** There is no debt screen, payment tracking, or balance calculation.
8. **There is no invoice history.** The `invoices` and `invoice_items` tables are only written by an unused DB method.
9. **Search is fragile.** It searches only the in-memory list, is case-sensitive, does not trim input, and returns the first product for an empty query.
10. **Arabic PDF output is likely broken.** No Arabic font is embedded, and the default PDF fonts do not shape Arabic text.
11. **There are no tests and no CI.** No `test/` directory exists, and `flutter analyze` is not enforced.
12. **The database has no migration strategy.** Schema version is fixed at 1, there is no `onUpgrade`, no indexes, and foreign keys are not enabled.
13. **The repository contains a duplicate nested project.** `trade_app/` is an identical copy and doubles analysis warnings.
14. **The release configuration is not production-ready.** It uses debug signing, `com.example.trade_app`, and the default Android label `trade_app`.
15. **The old README claimed features the code does not implement.** This document replaces those claims with an accurate status.

---

## Detailed limitations

### Domain and workflow

- No manual product creation, editing, or deletion.
- No supplier or customer management; names are free-text strings.
- No purchase invoice record; purchases are not auditable.
- No sales invoice persistence; no invoice number, date, customer, or payment status.
- No stock validation; a wired sales flow could produce negative quantities.
- No returns, refunds, discounts, taxes, or partial payments.
- No profit calculation despite the `profit` column.
- No debt management despite the `debts` table.
- No multi-currency support despite the old README claim.
- No unit model; `quantity`, `packQuantity`, and `totalQuantity` are ambiguous.

### Data layer

- `DBHelper` is a singleton with no injection or test seam.
- `insertProduct` uses `ConflictAlgorithm.replace`, which deletes and reinserts rows and can break foreign-key references.
- `insertInvoice` updates stock but is never called by the UI.
- Foreign keys are declared but not enforced without `PRAGMA foreign_keys = ON`.
- No indexes on `products.code`, `products.name`, `invoices.date`, or `invoice_items.invoiceId`.
- No database migrations or `onUpgrade`.
- No transactions around multi-row Excel imports.
- Dates are stored with `DateTime.now().toString()` and other string formats instead of ISO 8601.
- All data is unencrypted on the device; clearing app data or uninstalling removes it.
- No backup, restore, or export.

### Import and export

- Fixed column order with no header mapping.
- No support for `.xls`, CSV, or multiple sheets.
- No validation of required columns, numeric values, or duplicate codes.
- No preview-and-commit step.
- Synchronous file read on the UI isolate.
- No user-facing error messages for malformed files.
- PDF lacks an embedded Arabic font, invoice number, date, customer, currency, and tax.
- `pw.Table.fromTextArray` is deprecated in the installed `pdf` version.

### UI and state management

- `Future.microtask(loadProducts)` inside `build` can retrigger loads and cause unnecessary rebuilds.
- No loading, empty, or error states beyond a basic empty message.
- No product picker or add-to-cart interaction.
- No pagination; all products are loaded into memory.
- Hard-coded store name and low-stock threshold.
- Hard-coded Arabic strings; `supportedLocales` includes English but no English translations exist.
- No accessibility review, dark theme, or consistent design system.
- Material 3 is enabled while the theme still uses `primarySwatch`.

### Quality and release

- No unit, widget, or integration tests.
- No CI workflow for analyze, test, or build.
- No screenshots or demo video.
- No app icon or splash customization.
- Release build uses debug signing.
- Application ID is `com.example.trade_app`.
- Android label is `trade_app`, not the Arabic product name.
- Several declared dependencies are unused (`fl_chart`, `image_picker`, `share_plus`, and likely `path_provider`).
- No license file.

### Repository hygiene

- A nested `trade_app/` directory duplicates the entire source tree.
- Generated folders (`.dart_tool/`, `build/`, `.flutter-plugins*`) are correctly ignored, but the duplicate copy is not.
- `android/local.properties` is machine-specific and must never be committed.
- The repository has no screenshots, release notes, or issue templates.

---

## What should have been done from the start

1. **Finish one vertical slice before adding breadth.** Build product selection → cart → invoice save → stock decrement → PDF, then expand.
2. **Model purchases as invoices with line items.** A purchase should create an invoice and increment stock, not overwrite a product row.
3. **Use a repository/service layer with transactions.** Keep SQL out of screens and make the data layer testable.
4. **Add migrations from day one.** Use `onUpgrade`, indexes, and `PRAGMA foreign_keys = ON`.
5. **Validate imports before writing.** Preview the file, map headers, validate rows, show errors, and commit inside a transaction.
6. **Embed an Arabic font in the PDF.** Test Arabic shaping and RTL layout on a real device.
7. **Write tests for the data layer and money math.** Cover stock updates, invoice totals, profit, and import edge cases.
8. **Add backup and restore before calling the app usable.** Offline data is the user's only copy.
9. **Make currency and store settings explicit.** Store currency per invoice and keep exchange-rate logic out of the UI.
10. **Use a localization system.** Move Arabic strings to ARB files and add English only when it is complete.
11. **Clean the repository.** Remove the nested duplicate, dead dependencies, and generated files.
12. **Configure release builds properly.** Use a real application ID, release signing, app icon, and splash screen.
13. **Document reality in the README.** Keep implemented, partial, and planned features separate.

---

## Roadmap

### Phase 1 — Complete the sales vertical slice

- Add a product picker and quantity input.
- Populate the cart from real products.
- Validate stock before adding and before checkout.
- Save the invoice and invoice items in one transaction.
- Decrement stock atomically.
- Calculate line totals, invoice total, and profit.
- Embed an Arabic font and print a complete invoice.

### Phase 2 — Make purchasing real

- Create purchase invoices with line items.
- Increment stock instead of replacing product rows.
- Add supplier records.
- Add Excel preview, header mapping, validation, duplicate handling, and rollback.
- Parse large files off the UI isolate.

### Phase 3 — Reporting and debts

- Implement sales, profit, low-stock, and top-selling reports.
- Add charts with `fl_chart` (already declared).
- Add customer and supplier debt screens.
- Record payments and calculate balances.

### Phase 4 — Data safety and settings

- Add backup and restore to a file.
- Add store name, currency, and low-stock threshold settings.
- Add CSV/Excel export.
- Add database migrations and indexes.

### Phase 5 — Quality and release

- Add unit and widget tests.
- Add a CI workflow for analyze, test, and APK build.
- Add app icon, splash screen, and Arabic label.
- Configure release signing and a real application ID.
- Add screenshots and a short demo video.
- Add a license.

---

## Engineering retrospective

**What went well**

- The project established a working offline SQLite foundation.
- The Arabic RTL shell and module navigation are easy to understand.
- Excel parsing and PDF printing were explored early, which exposed the hard parts.
- The code is small enough to refactor quickly.

**What went wrong**

- Breadth came before depth: four modules exist, but the most important workflow does not.
- The database schema and README promised features that the UI never implemented.
- The sales screen was built around a cart that cannot be filled.
- Import writes were treated as product upserts instead of purchase transactions.
- No tests or migrations were added, so every schema change would be risky.
- A duplicate nested project was left in the repository.

**Lessons**

- A working vertical slice is more valuable than several partial screens.
- Domain modeling matters: purchases, sales, products, and payments are different things.
- Import features need validation and rollback, not just parsing.
- PDF and Arabic text require explicit font and shaping work.
- A README should describe what the code does, not what it was intended to do.

---

## Repository hygiene

Before publishing or accepting contributions:

- Remove the nested `trade_app/` duplicate.
- Keep `android/local.properties`, build outputs, and generated Flutter files out of Git.
- Add screenshots of the home, inventory, import, and sales screens.
- Add a license.
- Add a short demo video or GIF.
- Keep the README status table up to date.

---

## Author

**Ahlam Waheeb**
Computer Science / Artificial Intelligence student
GitHub: [github.com/Ah22lamo](https://github.com/Ah22lamo)

---

## License

No license has been added yet. Add one before distributing the project or accepting external contributions.
