import 'package:flutter/material.dart';
import '../models/shopping_item_model.dart';
import '../theme/theme.dart';

class ShoppingDetailScreen extends StatefulWidget {
  final ShoppingItemModel item;
  final Function(String) onToggleComplete;
  final Function(String) onDelete;

  const ShoppingDetailScreen({
    super.key,
    required this.item,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  State<ShoppingDetailScreen> createState() => _ShoppingDetailScreenState();
}

class _ShoppingDetailScreenState extends State<ShoppingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.item.isCompleted;

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
        title: Text(
          'Detail Barang Belanjaan',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: RetroTheme.darkCharcoal),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCompleted ? '✔ Sudah Dibeli' : '🛒 Belum Dibeli',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isCompleted ? const Color(0xFF047857) : const Color(0xFFC2410C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.item.title,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    _buildDetailRow('Kategori', widget.item.category),
                    const Divider(color: RetroTheme.borderLight, height: 24),
                    _buildDetailRow('Status Belanja', isCompleted ? 'Selesai' : 'Belum Selesai'),
                  ],
                ),
              ),
              const Spacer(),

              // Toggle Complete Status Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? const Color(0xFFF1F5F9) : RetroTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  widget.onToggleComplete(widget.item.id);
                  setState(() {});
                },
                icon: Icon(
                  isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded,
                  color: isCompleted ? RetroTheme.darkCharcoal : Colors.white,
                ),
                label: Text(
                  isCompleted ? 'Tandai Belum Dibeli' : 'Tandai Sudah Dibeli',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? RetroTheme.darkCharcoal : Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Delete Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  widget.onDelete(widget.item.id);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48)),
                label: const Text(
                  'Hapus Barang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE11D48),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: RetroTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: RetroTheme.darkCharcoal,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
