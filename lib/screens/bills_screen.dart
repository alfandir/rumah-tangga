import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill_model.dart';
import '../theme/theme.dart';
import 'bill_detail_screen.dart';

class BillsScreen extends StatefulWidget {
  final List<BillModel> bills;
  final Function(BillModel) onAddBill;
  final Function(String) onTogglePaid;
  final Function(String) onDeleteBill;

  const BillsScreen({
    super.key,
    required this.bills,
    required this.onAddBill,
    required this.onTogglePaid,
    required this.onDeleteBill,
  });

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dueDateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Tambah Tagihan Rutin',
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
                labelText: 'Nama Tagihan (contoh: Listrik PLN)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Estimasi Biaya (Rp)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dueDateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jatuh Tempo (Tanggal 1-31)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
              final amount = double.tryParse(_amountController.text) ?? 0.0;
              final dueDay = int.tryParse(_dueDateController.text) ?? 1;

              if (title.isNotEmpty && amount > 0) {
                widget.onAddBill(
                  BillModel(
                    id: DateTime.now().toString(),
                    title: title,
                    amount: amount,
                    dueDateDay: dueDay,
                  ),
                );
                _titleController.clear();
                _amountController.clear();
                _dueDateController.clear();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
              child: const Icon(Icons.receipt_long_rounded, color: RetroTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Tagihan Rutin Rumah Tangga',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: widget.bills.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada tagihan rutin tercatat',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.bills.length,
                        itemBuilder: (context, index) {
                          final bill = widget.bills[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BillDetailScreen(
                                      bill: bill,
                                      onTogglePaid: (id) {
                                        widget.onTogglePaid(id);
                                        setState(() {});
                                      },
                                      onDelete: widget.onDeleteBill,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: bill.isPaid
                                            ? const Color(0xFFD1FAE5)
                                            : const Color(0xFFFFE4E6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        bill.isPaid
                                            ? Icons.check_circle_outline_rounded
                                            : Icons.error_outline_rounded,
                                        color: bill.isPaid
                                            ? const Color(0xFF059669)
                                            : const Color(0xFFE11D48),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bill.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: RetroTheme.darkCharcoal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Tempo: Tgl ${bill.dueDateDay}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: RetroTheme.textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                currencyFormat.format(bill.amount),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: RetroTheme.darkCharcoal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: bill.isPaid
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFFFF1F2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        bill.isPaid ? 'Lunas' : 'Belum',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: bill.isPaid
                                              ? const Color(0xFF047857)
                                              : const Color(0xFFBE123C),
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'bills_fab',
        onPressed: _showAddDialog,
        backgroundColor: RetroTheme.primaryBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Tagihan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
