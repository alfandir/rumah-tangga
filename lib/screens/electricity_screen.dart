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
  final _amountController = TextEditingController();
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

  // Hitung rata-rata pemakaian kWh per hari berdasarkan riwayat
  double get averageDailyKwh {
    if (widget.records.length < 2) {
      if (widget.records.isNotEmpty) {
        // Asumsi standar 30 hari untuk 1 record
        return widget.records.first.kwhObtained / 30.0;
      }
      return 0.0;
    }

    // Urutkan berdasarkan tanggal tertua ke terbaru
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

    if (totalDaysSum > 0) {
      return totalKwhSum / totalDaysSum;
    }
    return 0.0;
  }

  // Hitung estimasi tanggal pembelian berikutnya berdasarkan record terakhir
  DateTime? get estimatedNextPurchaseDate {
    if (widget.records.isEmpty) return null;

    final sorted = List<ElectricityRecordModel>.from(widget.records)
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    final lastRecord = sorted.first;
    final dailyKwh = averageDailyKwh;

    if (dailyKwh <= 0) return null;

    final estimatedDaysDuration = (lastRecord.kwhObtained / dailyKwh).round();
    return lastRecord.purchaseDate.add(Duration(days: estimatedDaysDuration));
  }

  void _showAddDialog() {
    _amountController.text = '100000';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final amount = double.tryParse(_amountController.text) ?? 0.0;
          final tariff = _vaTariffs[_selectedVa] ?? 1444.70;
          final estimatedKwh = amount > 0 ? (amount / tariff) : 0.0;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Isi Token Listrik Baru',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: RetroTheme.darkCharcoal,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daya Listrik (VA)', style: TextStyle(fontSize: 13, color: RetroTheme.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedVa,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _vaTariffs.keys
                        .map((va) => DropdownMenuItem(
                              value: va,
                              child: Text(va, style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          _selectedVa = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Nominal Isi Token (Rp)', style: TextStyle(fontSize: 13, color: RetroTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Contoh: 100000',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Live Calculator Badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RetroTheme.softBlueBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RetroTheme.primaryBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimasi Daya kWh:',
                          style: TextStyle(fontSize: 13, color: RetroTheme.darkCharcoal),
                        ),
                        Text(
                          '${estimatedKwh.toStringAsFixed(1)} kWh',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: RetroTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                  final amountVal = double.tryParse(_amountController.text) ?? 0.0;
                  final tariffVal = _vaTariffs[_selectedVa] ?? 1444.70;

                  if (amountVal > 0) {
                    widget.onAddRecord(
                      ElectricityRecordModel(
                        id: DateTime.now().toString(),
                        purchaseDate: _selectedDate,
                        amount: amountVal,
                        tariffPerKwh: tariffVal,
                        powerVa: _selectedVa,
                      ),
                    );
                    _amountController.clear();
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text(
                  'Simpan Pembelian',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
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
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Kalkulator & Pemakaian Listrik',
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
              // Hero Summary Card: Average Daily kWh & Next Estimated Date
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFB45309)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x25D97706),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Rata-rata Pemakaian',
                              style: TextStyle(color: Color(0xFFFEF3C7), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dailyAvg.toStringAsFixed(1)} kWh/hari',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 40, color: Colors.white24),
                        Column(
                          children: [
                            const Text(
                              'Estimasi Isi Token Lagi',
                              style: TextStyle(color: Color(0xFFFEF3C7), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextDate != null
                                  ? DateFormat('dd MMM yyyy').format(nextDate)
                                  : 'Belum cukup data',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Isi Token Listrik',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17),
                  ),
                  Text(
                    '${sortedRecords.length} Transaksi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // List of Purchases
              Expanded(
                child: sortedRecords.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada riwayat pembelian token listrik',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: sortedRecords.length,
                        itemBuilder: (context, index) {
                          final record = sortedRecords[index];
                          final kwh = record.kwhObtained;

                          // Hitung selisih hari dengan transaksi berikutnya jika ada
                          int? daysDuration;
                          double? dailyUsageForRecord;
                          if (index > 0) {
                            final newerRecord = sortedRecords[index - 1];
                            daysDuration = newerRecord.purchaseDate.difference(record.purchaseDate).inDays;
                            if (daysDuration > 0) {
                              dailyUsageForRecord = kwh / daysDuration;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: RetroTheme.retroBoxDecoration(color: Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              record.powerVa,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat('dd MMM yyyy').format(record.purchaseDate),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: RetroTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                                        onPressed: () => widget.onDeleteRecord(record.id),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currencyFormat.format(record.amount),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: RetroTheme.darkCharcoal,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Mendapatkan ${kwh.toStringAsFixed(1)} kWh',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: RetroTheme.primaryBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (daysDuration != null && daysDuration > 0)
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Bertahan: $daysDuration Hari',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: RetroTheme.darkCharcoal,
                                                ),
                                              ),
                                              if (dailyUsageForRecord != null)
                                                Text(
                                                  '${dailyUsageForRecord.toStringAsFixed(1)} kWh/hari',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: RetroTheme.textSecondary,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'electricity_fab',
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFD97706),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: const Icon(Icons.bolt_rounded, color: Colors.white),
        label: const Text(
          'Isi Token Listrik',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
