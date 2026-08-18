class ShoppingItemModel {
  final String id;
  final String title;
  final String category; // e.g., 'Dapur', 'Mandi', 'Lainnya'
  bool isCompleted;

  ShoppingItemModel({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
  });
}
