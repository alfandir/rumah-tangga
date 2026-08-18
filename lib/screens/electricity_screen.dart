import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/electricity_record_model.dart';
import '../theme/theme.dart';

class ElectricityScreen extends StatefulWidget {
  final List<ElectricityRecordModel> records;
  final Function(ElectricityRecordModel) onAddRecord;
  final Function(String) onDeleteRecord;

  const ElectricityScreen({
    super.key,
    required this.records,
    required this.onAddRecord,
    required this.onDeleteRecord,
  });

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  final _amountController = TextEditingController(text: '100000');
  final DateTime _selectedDate = DateTime.now();
  String _selectedVa = '1300 VA';

  final Map<String, double> _vaTariffs = {
    '900 VA (Subsidi)': 605.0,
    '900 VA (Non-Subsidi)': 1352.0,
    '1300 VA': 1444.70,
    '2200 VA': 1444.70,
    '3500 VA+': 1699.53,
  };

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get currentAmount => double.tryParse(_amountController.text) ?? 0.0;
  double get currentTariff => _vaTariffs[_selectedVa] ?? 1444.70;
  double get currentKwh => currentAmount > 0 ? (currentAmount / currentTariff) : 0.0;

  double get averageDailyKwh {
    if (widget.records.length < 2) {
      if (widget.records.isNotEmpty) {
        return widget.records.first.kwhObtained / 30.0;
      }
      return 0.0;
    }

    final sorted = List<ElectricityRecordModel>.from(widget.records)
      ..sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));

    double totalKwhSum = 0;
    int totalDaysSum = 0;

    for (int i = 0; i < sorted.length - 1; i++) {
      final current = sorted[i];
      final next = sorted[i + 1];
      final daysBetween = next.purchaseDate.difference(current.purchaseDate).inDays;
      if (daysBetween > 0) {
        totalKwhSum += current.kwhObtained;
        totalDaysSum += daysBetween;
      }
    }

    return totalDaysSum > 0 ? (totalKwhSum / totalDaysSum) : 0.0;
  }

  DateTime? get estimatedNextPurchaseDate {
    if (widget.records.isEmpty) return null;

    final sorted = List<ElectricityRecordModel>.from(widget.records)
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    final lastRecord = sorted.first;
    final dailyKwh = averageDailyKwh;

    if (dailyKwh <= 0) return null;

    final estimatedDays = (lastRecord.kwhObtained / dailyKwh).round();
    return lastRecord.purchaseDate.add(Duration(days: estimatedDays));
  }

  void _saveRecord() {
    if (currentAmount > 0) {
      widget.onAddRecord(
        ElectricityRecordModel(
          id: DateTime.now().toString(),
          purchaseDate: _selectedDate,
          amount: currentAmount,
          tariffPerKwh: currentTariff,
          powerVa: _selectedVa,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembelian token berhasil disimpan'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final sortedRecords = List<ElectricityRecordModel>.from(widget.records)
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    final dailyAvg = averageDailyKwh;
    final nextDate = estimatedNextPurchaseDate;

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
              child: const Icon(Icons.bolt_rounded, color: RetroTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Kalkulator Listrik',
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
              // Harmonized Calculator Form Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVa,
                      decoration: InputDecoration(
                        labelText: 'Daya Listrik',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _vaTariffs.keys
                          .map((va) => DropdownMenuItem(value: va, child: Text(va)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedVa = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Nominal Token (Rp)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Harmonized Calculation Result Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: RetroTheme.softBlueBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dapat kWh', style: TextStyle(fontSize: 12, color: RetroTheme.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                '${currentKwh.toStringAsFixed(1)} kWh',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: RetroTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Estimasi Beli Lagi', style: TextStyle(fontSize: 12, color: RetroTheme.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                nextDate != null
                                    ? DateFormat('dd MMM yyyy').format(nextDate)
                                    : '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: RetroTheme.darkCharcoal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    ElevatedButton(
                      onPressed: _saveRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RetroTheme.primaryBlue,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Simpan Pembelian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Harmonized Average Usage Card
              if (dailyAvg > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: RetroTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Rata-rata pemakaian: ${dailyAvg.toStringAsFixed(1)} kWh/hari',
                        style: const TextStyle(fontSize: 13, color: RetroTheme.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

              Text(
                'Riwayat Pembelian',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 10),

              // Harmonized List Cards (Same style as Dashboard & Bills)
              Expanded(
                child: sortedRecords.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada riwayat pembelian token',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: sortedRecords.length,
                        itemBuilder: (context, index) {
                          final record = sortedRecords[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: RetroTheme.softBlueBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.bolt_rounded,
                                      color: RetroTheme.primaryBlue,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currencyFormat.format(record.amount),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: RetroTheme.darkCharcoal,
                                          ),
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
                                                record.powerVa,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: RetroTheme.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              DateFormat('dd MMM yyyy').format(record.purchaseDate),
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
                                    '${record.kwhObtained.toStringAsFixed(1)} kWh',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: RetroTheme.primaryBlue,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                                    onPressed: () => widget.onDeleteRecord(record.id),
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
