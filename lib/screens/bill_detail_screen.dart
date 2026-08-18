import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill_model.dart';
import '../theme/theme.dart';

class BillDetailScreen extends StatefulWidget {
  final BillModel bill;
  final Function(String) onTogglePaid;
  final Function(String) onDelete;

  const BillDetailScreen({
    super.key,
    required this.bill,
    required this.onTogglePaid,
    required this.onDelete,
  });

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isPaid = widget.bill.isPaid;

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
          'Detail Tagihan Rutin',
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
                        color: isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPaid ? '✔ Lunas' : '⏳ Belum Dibayar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isPaid ? const Color(0xFF047857) : const Color(0xFFBE123C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.bill.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currencyFormat.format(widget.bill.amount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: RetroTheme.darkCharcoal,
                        letterSpacing: -0.5,
                      ),
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
                    _buildDetailRow('Jatuh Tempo', 'Setiap Tanggal ${widget.bill.dueDateDay}'),
                    const Divider(color: RetroTheme.borderLight, height: 24),
                    _buildDetailRow('Status Pembayaran', isPaid ? 'Lunas' : 'Belum Lunas'),
                  ],
                ),
              ),
              const Spacer(),

              // Toggle Paid Status Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaid ? const Color(0xFFF1F5F9) : RetroTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  widget.onTogglePaid(widget.bill.id);
                  setState(() {});
                },
                icon: Icon(
                  isPaid ? Icons.undo_rounded : Icons.check_circle_rounded,
                  color: isPaid ? RetroTheme.darkCharcoal : Colors.white,
                ),
                label: Text(
                  isPaid ? 'Tandai Belum Lunas' : 'Tandai Sudah Lunas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPaid ? RetroTheme.darkCharcoal : Colors.white,
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
                  widget.onDelete(widget.bill.id);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48)),
                label: const Text(
                  'Hapus Tagihan',
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
