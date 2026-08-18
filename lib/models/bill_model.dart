class BillModel {
  final String id;
  final String title;
  final double amount;
  final int dueDateDay; // e.g. 20 for 20th of every month
  bool isPaid;

  BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDateDay,
    this.isPaid = false,
  });
}
