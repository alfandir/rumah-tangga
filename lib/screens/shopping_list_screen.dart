import 'package:flutter/material.dart';
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
  String _selectedCategory = 'Dapur';

  final List<String> _categories = ['Dapur', 'Mandi', 'Bersih-Bersih', 'Lainnya'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
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
                  labelText: 'Nama Barang (contoh: Minyak Goreng)',
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
                if (title.isNotEmpty) {
                  widget.onAddItem(
                    ShoppingItemModel(
                      id: DateTime.now().toString(),
                      title: title,
                      category: _selectedCategory,
                    ),
                  );
                  _titleController.clear();
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text(
                'Simpan',
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

  @override
  Widget build(BuildContext context) {
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
              'Catatan Belanja Dapur & Rumah',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: widget.items.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada daftar belanjaan',
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
                          child: Row(
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
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
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
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Kategori: ${item.category}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: RetroTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: item.isCompleted
                                      ? const Color(0xFFECFDF5)
                                      : const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.isCompleted ? 'Sudah Dibeli' : 'Belum',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
                        ),
                      ),
                    );
                  },
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
