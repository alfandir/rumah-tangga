import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../theme/theme.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  const AnalyticsScreen({super.key, required this.transactions});

  Map<String, double> get categoryExpenses {
    final Map<String, double> map = {};
    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return map;
  }

  double get totalExpense {
    return categoryExpenses.values.fold(0.0, (sum, val) => sum + val);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final expenses = categoryExpenses;
    final sortedCategories = expenses.keys.toList()
      ..sort((a, b) => expenses[b]!.compareTo(expenses[a]!));

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
              child: const Icon(Icons.pie_chart_rounded, color: RetroTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Analisis & Statistik Pengeluaran',
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
              // Summary Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL PENGELUARAN BULAN INI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: RetroTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormat.format(totalExpense),
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

              Text(
                'Persentase Pengeluaran per Kategori',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada data pengeluaran',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: sortedCategories.length,
                        itemBuilder: (context, index) {
                          final category = sortedCategories[index];
                          final amount = expenses[category]!;
                          final percentage =
                              totalExpense > 0 ? (amount / totalExpense) : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        category,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: RetroTheme.darkCharcoal,
                                        ),
                                      ),
                                      Text(
                                        '${currencyFormat.format(amount)} (${(percentage * 100).toStringAsFixed(1)}%)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: RetroTheme.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: percentage.clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        index % 2 == 0
                                            ? const Color(0xFF0284C7)
                                            : const Color(0xFF38BDF8),
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
}
