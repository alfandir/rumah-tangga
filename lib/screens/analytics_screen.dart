import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../theme/theme.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<TransactionModel> transactions;

  const AnalyticsScreen({super.key, required this.transactions});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedChartTab = 0; // 0: Donut Chart, 1: Bar Chart

  final List<Color> _chartColors = const [
    Color(0xFF0284C7), // Sky Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald Green
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF64748B), // Slate
    Color(0xFFF97316), // Orange
  ];

  Map<String, double> get categoryExpenses {
    final Map<String, double> map = {};
    for (var tx in widget.transactions) {
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
              'Grafik & Statistik Pengeluaran',
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
              // Total Summary Banner Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL PENGELUARAN BULAN INI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: RetroTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalExpense),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: RetroTheme.darkCharcoal,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Segmented Chart Toggle Button
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedChartTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedChartTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedChartTab == 0
                                ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.donut_large_rounded,
                                size: 18,
                                color: _selectedChartTab == 0 ? RetroTheme.primaryBlue : RetroTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Grafik Donut',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedChartTab == 0 ? RetroTheme.primaryBlue : RetroTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedChartTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedChartTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedChartTab == 1
                                ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                size: 18,
                                color: _selectedChartTab == 1 ? RetroTheme.primaryBlue : RetroTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Grafik Batang',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedChartTab == 1 ? RetroTheme.primaryBlue : RetroTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Visual Chart Container with Embedded Legend & Percentage Indicators
              Container(
                padding: const EdgeInsets.all(20),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: expenses.isEmpty
                    ? const SizedBox(
                        height: 180,
                        child: Center(
                          child: Text(
                            'Belum ada data pengeluaran untuk ditampilkan pada grafik',
                            style: TextStyle(color: RetroTheme.textSecondary, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          _selectedChartTab == 0
                              ? _buildDonutChart(sortedCategories, expenses)
                              : _buildBarChart(sortedCategories, expenses, currencyFormat),
                          const SizedBox(height: 18),
                          const Divider(color: RetroTheme.borderLight, height: 1),
                          const SizedBox(height: 14),
                          // Embedded Legend inside Chart Box
                          _buildChartLegend(sortedCategories),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              Text(
                'Rincian per Kategori',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Detailed Category List
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
                          final percentage = totalExpense > 0 ? (amount / totalExpense) : 0.0;
                          final color = _chartColors[index % _chartColors.length];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: RetroTheme.darkCharcoal,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(percentage * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: RetroTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    currencyFormat.format(amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: RetroTheme.darkCharcoal,
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

  // Embedded Chart Legend Component
  Widget _buildChartLegend(List<String> sortedCategories) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 8,
      children: List.generate(sortedCategories.length, (index) {
        final category = sortedCategories[index];
        final color = _chartColors[index % _chartColors.length];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              category,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: RetroTheme.darkCharcoal,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDonutChart(List<String> sortedCategories, Map<String, double> expenses) {
    final values = sortedCategories.map((c) => expenses[c]!).toList();
    final colors = List.generate(
      sortedCategories.length,
      (i) => _chartColors[i % _chartColors.length],
    );

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _DonutChartPainter(
              values: values,
              colors: colors,
              total: totalExpense,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pengeluaran',
                style: TextStyle(
                  fontSize: 11,
                  color: RetroTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${sortedCategories.length} Kategori',
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
    );
  }

  Widget _buildBarChart(
    List<String> sortedCategories,
    Map<String, double> expenses,
    NumberFormat currencyFormat,
  ) {
    final maxVal = expenses.values.reduce(max);
    final percentageLabels = ['100%', '75%', '50%', '25%', '0%'];

    return SizedBox(
      height: 190,
      child: Stack(
        children: [
          // Percentage Gridlines with Label Texts (100%, 75%, 50%, 25%, 0%)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          percentageLabels[index],
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: RetroTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFF1F5F9),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          // Bar Chart Columns with left offset to make room for percentage labels
          Padding(
            padding: const EdgeInsets.only(left: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(sortedCategories.length, (index) {
                final category = sortedCategories[index];
                final amount = expenses[category]!;
                final ratio = maxVal > 0 ? (amount / maxVal) : 0.0;
                final color = _chartColors[index % _chartColors.length];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(amount / 1000).toStringAsFixed(0)}rb',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: RetroTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: max(12.0, 110 * ratio),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(80),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 44,
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: RetroTheme.darkCharcoal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk grafik Donut / Pie Chart dengan Garis Penunjuk & Label Persentase (%)
class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double total;

  _DonutChartPainter({
    required this.values,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || values.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.3;
    const strokeWidth = 22.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * pi;
      paint.color = colors[i];

      // Draw Arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle,
        sweepAngle - 0.03, // gap antar arc
        false,
        paint,
      );

      // Draw Percentage Callout Label Lines & Text
      final percentage = (values[i] / total) * 100;
      if (percentage >= 3.0) {
        final midAngle = startAngle + (sweepAngle / 2);

        // Callout Line start & end point
        final lineStart = Offset(
          center.dx + (radius + 2) * cos(midAngle),
          center.dy + (radius + 2) * sin(midAngle),
        );
        final lineEnd = Offset(
          center.dx + (radius + 12) * cos(midAngle),
          center.dy + (radius + 12) * sin(midAngle),
        );

        final linePaint = Paint()
          ..color = colors[i]
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        canvas.drawLine(lineStart, lineEnd, linePaint);

        // Percentage Text Label Badge
        final textSpan = TextSpan(
          text: '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            color: colors[i],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();

        final labelPos = Offset(
          lineEnd.dx - (textPainter.width / 2) + (cos(midAngle) * 8),
          lineEnd.dy - (textPainter.height / 2) + (sin(midAngle) * 8),
        );

        textPainter.paint(canvas, labelPos);
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.total != total;
  }
}
