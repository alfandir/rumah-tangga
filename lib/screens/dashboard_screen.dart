import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../theme/theme.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  final VoidCallback onNavigateToAdd;
  final Function(String) onDeleteTransaction;
  final double monthlyBudget;

  const DashboardScreen({
    super.key,
    required this.transactions,
    required this.onNavigateToAdd,
    required this.onDeleteTransaction,
    this.monthlyBudget = 3000000.0,
  });

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpense;

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'listrik':
        return Icons.bolt_rounded;
      case 'sampah':
        return Icons.delete_outline_rounded;
      case 'belanja':
        return Icons.shopping_bag_outlined;
      case 'gaji':
        return Icons.payments_outlined;
      case 'internet':
        return Icons.wifi_rounded;
      case 'hiburan':
        return Icons.sports_esports_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'listrik':
        return const Color(0xFFFEF3C7); // Soft Amber
      case 'sampah':
        return const Color(0xFFF1F5F9); // Soft Slate
      case 'belanja':
        return const Color(0xFFE0F2FE); // Soft Sky
      case 'gaji':
        return const Color(0xFFD1FAE5); // Soft Emerald
      case 'internet':
        return const Color(0xFFF3E8FF); // Soft Purple
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final budgetUsageRatio = monthlyBudget > 0 ? (totalExpense / monthlyBudget) : 0.0;
    final isOverBudget = totalExpense > monthlyBudget;

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
              child: const Icon(Icons.home_rounded, color: RetroTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Keuangan Rumah Tangga',
              style: Theme.of(context).textTheme.headlineMedium,
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
              // Modern Hero Saldo Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x250284C7),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sisa Saldo Saat Ini',
                          style: TextStyle(
                            color: Color(0xFFE0F2FE),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isOverBudget)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFECDD3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Over Budget',
                              style: TextStyle(
                                color: Color(0xFF9F1239),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF047857), size: 16),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pemasukan',
                                      style: TextStyle(color: Color(0xFFE0F2FE), fontSize: 11),
                                    ),
                                    Text(
                                      currencyFormat.format(totalIncome),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 30, color: Colors.white24),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFE4E6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.arrow_upward_rounded, color: Color(0xFFBE123C), size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pengeluaran',
                                        style: TextStyle(color: Color(0xFFE0F2FE), fontSize: 11),
                                      ),
                                      Text(
                                        currencyFormat.format(totalExpense),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Modern Budget Progress Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Batas Anggaran Bulanan',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '${(budgetUsageRatio * 100).toStringAsFixed(0)}% (${currencyFormat.format(monthlyBudget)})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isOverBudget ? Colors.red[700] : RetroTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: budgetUsageRatio.clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverBudget ? const Color(0xFFEF4444) : const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Transaksi',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17),
                  ),
                  Text(
                    '${transactions.length} Item',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Clean Transaction List
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada transaksi tercatat',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final isIncome = tx.type == TransactionType.income;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TransactionDetailScreen(
                                      transaction: tx,
                                      onDelete: onDeleteTransaction,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(tx.category),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(tx.category),
                                        color: RetroTheme.darkCharcoal,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.title,
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
                                                  tx.category,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: RetroTheme.textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                DateFormat('dd MMM yyyy').format(tx.date),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: RetroTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      (isIncome ? '+ ' : '- ') + currencyFormat.format(tx.amount),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
        heroTag: 'dashboard_fab',
        onPressed: onNavigateToAdd,
        backgroundColor: RetroTheme.primaryBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Transaksi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
