import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shopping_item_model.dart';
import '../theme/theme.dart';
import 'shopping_detail_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  final List<ShoppingItemModel> items;
  final Function(ShoppingItemModel) onAddItem;
  final Function(String) onToggleComplete;
  final Function(String) onDeleteItem;

  const ShoppingListScreen({
    super.key,
    required this.items,
    required this.onAddItem,
    required this.onToggleComplete,
    required this.onDeleteItem,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Dapur';

  final List<String> _categories = ['Dapur', 'Mandi', 'Bersih-Bersih', 'Lainnya'];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get totalMonthlyEstimate {
    final now = DateTime.now();
    return widget.items
        .where((item) => item.date.month == now.month && item.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.price);
  }

  double get totalMonthlyPurchased {
    final now = DateTime.now();
    return widget.items
        .where((item) => item.isCompleted && item.date.month == now.month && item.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.price);
  }

  void _showAddDialog() {
    _priceController.text = '';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Tambah Barang Belanjaan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: RetroTheme.darkCharcoal,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Nama Barang (contoh: Beras 5kg)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Estimasi Harga / Biaya (Rp)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori Barang',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: RetroTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                final title = _titleController.text;
                final priceVal = double.tryParse(_priceController.text) ?? 0.0;

                if (title.isNotEmpty) {
                  widget.onAddItem(
                    ShoppingItemModel(
                      id: DateTime.now().toString(),
                      title: title,
                      category: _selectedCategory,
                      price: priceVal,
                      date: DateTime.now(),
                    ),
                  );
                  _titleController.clear();
                  _priceController.clear();
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text(
                'Simpan Barang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMonth(DateTime date) {
    try {
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('MMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final monthName = _formatMonth(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(
            color: RetroTheme.borderLight,
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: RetroTheme.softBlueBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_cart_rounded, color: RetroTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Belanja Bulanan ($monthName)',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Monthly Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Estimasi Belanja',
                          style: TextStyle(fontSize: 12, color: RetroTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(totalMonthlyEstimate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: RetroTheme.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 36, color: RetroTheme.borderLight),
                    Column(
                      children: [
                        const Text(
                          'Sudah Dibeli (Potong Saldo)',
                          style: TextStyle(fontSize: 12, color: RetroTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(totalMonthlyPurchased),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: widget.items.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada daftar belanjaan bulan ini',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ShoppingDetailScreen(
                                      item: item,
                                      onToggleComplete: (id) {
                                        widget.onToggleComplete(id);
                                        setState(() {});
                                      },
                                      onDelete: widget.onDeleteItem,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: RetroTheme.retroBoxDecoration(
                                  color: item.isCompleted
                                      ? const Color(0xFFF8FAFC)
                                      : Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '🛒 ${item.category}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: RetroTheme.textSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: item.isCompleted
                                                    ? const Color(0xFFECFDF5)
                                                    : const Color(0xFFFFF7ED),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                item.isCompleted ? '✔ Sudah Dibeli' : '⏳ Belum Dibeli',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: item.isCompleted
                                                      ? const Color(0xFF047857)
                                                      : const Color(0xFFC2410C),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              color: Color(0xFF94A3B8),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => widget.onToggleComplete(item.id),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: item.isCompleted
                                                  ? const Color(0xFF0284C7)
                                                  : Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: item.isCompleted
                                                    ? const Color(0xFF0284C7)
                                                    : const Color(0xFFCBD5E1),
                                                width: 2,
                                              ),
                                            ),
                                            child: item.isCompleted
                                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: item.isCompleted
                                                  ? RetroTheme.textSecondary
                                                  : RetroTheme.darkCharcoal,
                                              decoration: item.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                        if (item.price > 0)
                                          Text(
                                            currencyFormat.format(item.price),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: item.isCompleted
                                                  ? const Color(0xFF059669)
                                                  : RetroTheme.darkCharcoal,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'shopping_fab',
        onPressed: _showAddDialog,
        backgroundColor: RetroTheme.primaryBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Barang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
