class ElectricityRecordModel {
  final String id;
  final DateTime purchaseDate;
  final double amount; // Nominal Pembelian Token (e.g. 100000)
  final double tariffPerKwh; // Tarif per kWh (e.g. 1444.70)
  final String powerVa; // Daya Listrik (e.g. '1300 VA')

  ElectricityRecordModel({
    required this.id,
    required this.purchaseDate,
    required this.amount,
    required this.tariffPerKwh,
    required this.powerVa,
  });

  // Hitung Estimasi kWh yang didapat dari nominal pembelian
  double get kwhObtained => amount > 0 && tariffPerKwh > 0 ? (amount / tariffPerKwh) : 0.0;
}
