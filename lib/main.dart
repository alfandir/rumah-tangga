import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/transaction_model.dart';
import 'models/bill_model.dart';
import 'models/shopping_item_model.dart';
import 'models/electricity_record_model.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/bills_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/electricity_screen.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const RumahTanggaApp());
}

class RumahTanggaApp extends StatefulWidget {
  const RumahTanggaApp({super.key});

  @override
  State<RumahTanggaApp> createState() => _RumahTanggaAppState();
}

class _RumahTanggaAppState extends State<RumahTanggaApp> {
  int _currentIndex = 0;

  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: '1',
      title: 'Bayar Listrik',
      amount: 150000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.expense,
      category: 'Listrik',
    ),
    TransactionModel(
      id: '2',
      title: 'Uang Sampah Bulanan',
      amount: 25000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.expense,
      category: 'Sampah',
    ),
    TransactionModel(
      id: '3',
      title: 'Gaji Bulanan',
      amount: 5000000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: TransactionType.income,
      category: 'Gaji',
    ),
  ];

  final List<BillModel> _bills = [
    BillModel(id: 'b1', title: 'Listrik PLN', amount: 150000, dueDateDay: 20, isPaid: true),
    BillModel(id: 'b2', title: 'Iuran Sampah & Keamanan', amount: 35000, dueDateDay: 5, isPaid: false),
    BillModel(id: 'b3', title: 'WiFi Indihome', amount: 320000, dueDateDay: 15, isPaid: false),
  ];

  final List<ShoppingItemModel> _shoppingItems = [
    ShoppingItemModel(id: 's1', title: 'Beras 5kg', category: 'Dapur', price: 75000, date: DateTime.now(), isCompleted: false),
    ShoppingItemModel(id: 's2', title: 'Minyak Goreng 2L', category: 'Dapur', price: 35000, date: DateTime.now(), isCompleted: true),
    ShoppingItemModel(id: 's3', title: 'Sabun Cuci Piring', category: 'Bersih-Bersih', price: 15000, date: DateTime.now(), isCompleted: false),
  ];

  final List<ElectricityRecordModel> _electricityRecords = [
    ElectricityRecordModel(
      id: 'e1',
      purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
      amount: 100000,
      tariffPerKwh: 1444.70,
      powerVa: '1300 VA',
    ),
    ElectricityRecordModel(
      id: 'e2',
      purchaseDate: DateTime.now(),
      amount: 100000,
      tariffPerKwh: 1444.70,
      powerVa: '1300 VA',
    ),
  ];

  void _addTransaction(TransactionModel tx) {
    setState(() {
      _transactions.add(tx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _addBill(BillModel bill) {
    setState(() {
      _bills.add(bill);
    });
  }

  void _toggleBillPaid(String id) {
    setState(() {
      final index = _bills.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bills[index].isPaid = !_bills[index].isPaid;
      }
    });
  }

  void _deleteBill(String id) {
    setState(() {
      _bills.removeWhere((b) => b.id == id);
    });
  }

  void _addShoppingItem(ShoppingItemModel item) {
    setState(() {
      _shoppingItems.add(item);
    });
  }

  void _toggleShoppingItem(String id) {
    setState(() {
      final index = _shoppingItems.indexWhere((s) => s.id == id);
      if (index != -1) {
        final item = _shoppingItems[index];
        final newStatus = !item.isCompleted;
        item.isCompleted = newStatus;

        final txId = 'shop_tx_${item.id}';
        if (newStatus && item.price > 0) {
          // Otomatis buat pengeluaran yang memotong saldo/pemasukan!
          _transactions.removeWhere((tx) => tx.id == txId);
          _transactions.add(
            TransactionModel(
              id: txId,
              title: 'Belanja: ${item.title}',
              amount: item.price,
              date: DateTime.now(),
              type: TransactionType.expense,
              category: 'Belanja',
            ),
          );
        } else {
          // Hapus pengeluaran jika batal dibeli
          _transactions.removeWhere((tx) => tx.id == txId);
        }
      }
    });
  }

  void _deleteShoppingItem(String id) {
    setState(() {
      _shoppingItems.removeWhere((s) => s.id == id);
      _transactions.removeWhere((tx) => tx.id == 'shop_tx_$id');
    });
  }

  void _addElectricityRecord(ElectricityRecordModel record) {
    setState(() {
      _electricityRecords.add(record);
      _transactions.add(
        TransactionModel(
          id: record.id,
          title: 'Token Listrik PLN (${record.kwhObtained.toStringAsFixed(1)} kWh)',
          amount: record.amount,
          date: record.purchaseDate,
          type: TransactionType.expense,
          category: 'Listrik',
        ),
      );
    });
  }

  void _deleteElectricityRecord(String id) {
    setState(() {
      _electricityRecords.removeWhere((e) => e.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      Builder(
        builder: (ctx) => DashboardScreen(
          transactions: _transactions,
          onNavigateToAdd: () {
            Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => AddTransactionScreen(onSave: _addTransaction),
              ),
            );
          },
          onDeleteTransaction: _deleteTransaction,
          onOpenElectricity: () {
            setState(() {
              _currentIndex = 3; // Switch to Electricity Tab
            });
          },
        ),
      ),
      BillsScreen(
        bills: _bills,
        onAddBill: _addBill,
        onTogglePaid: _toggleBillPaid,
        onDeleteBill: _deleteBill,
      ),
      ShoppingListScreen(
        items: _shoppingItems,
        onAddItem: _addShoppingItem,
        onToggleComplete: _toggleShoppingItem,
        onDeleteItem: _deleteShoppingItem,
      ),
      ElectricityScreen(
        records: _electricityRecords,
        onAddRecord: _addElectricityRecord,
        onDeleteRecord: _deleteElectricityRecord,
      ),
      AnalyticsScreen(transactions: _transactions),
    ];

    return MaterialApp(
      title: 'Keuangan Rumah Tangga',
      theme: RetroTheme.themeData,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: RetroTheme.borderLight,
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: RetroTheme.primaryBlue,
            unselectedItemColor: RetroTheme.textSecondary,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 11,
            ),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Transaksi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Tagihan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart_rounded),
                label: 'Belanja',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bolt_outlined),
                activeIcon: Icon(Icons.bolt_rounded),
                label: 'Listrik',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_outline_rounded),
                activeIcon: Icon(Icons.pie_chart_rounded),
                label: 'Statistik',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
