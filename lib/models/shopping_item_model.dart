class ShoppingItemModel {
  final String id;
  final String title;
  final String category; // e.g., 'Dapur', 'Mandi', 'Bersih-Bersih'
  final double price; // Harga/Estimasi Biaya
  final DateTime date; // Tanggal/Bulan belanja
  bool isCompleted;

  ShoppingItemModel({
    required this.id,
    required this.title,
    required this.category,
    this.price = 0.0,
    required this.date,
    this.isCompleted = false,
  });
}
