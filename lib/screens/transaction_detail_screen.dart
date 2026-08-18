import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../theme/theme.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;
  final Function(String) onDelete;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  String _formatFullDate(DateTime date) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isIncome = transaction.type == TransactionType.income;

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
          'Detail Transaksi',
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
              // Main Card Display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isIncome ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isIncome ? 'Pemasukan' : 'Pengeluaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isIncome ? const Color(0xFF047857) : const Color(0xFFBE123C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (isIncome ? '+ ' : '- ') + currencyFormat.format(transaction.amount),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Metadata Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    _buildDetailRow('Kategori', transaction.category),
                    const Divider(color: RetroTheme.borderLight, height: 24),
                    _buildDetailRow('Tanggal', _formatFullDate(transaction.date)),
                    const Divider(color: RetroTheme.borderLight, height: 24),
                    _buildDetailRow('ID Transaksi', transaction.id.substring(0, transaction.id.length > 8 ? 8 : transaction.id.length)),
                  ],
                ),
              ),
              const Spacer(),

              // Delete Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFFECDD3)),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  onDelete(transaction.id);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48)),
                label: const Text(
                  'Hapus Transaksi',
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
