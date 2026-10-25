enum PaymentStatus { paid, verifying, pending, failed }

class PaymentRecord {
  final String id;
  final String title;
  final double amount;
  final String date;
  final String method;
  final String utrNumber;
  final PaymentStatus status;
  final String receiptUrl;

  const PaymentRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.method,
    required this.utrNumber,
    required this.status,
    required this.receiptUrl,
  });
}

class FeeBreakdown {
  final double rentAmount;
  final double messAmount;
  final double utilityAmount;
  final double lateFee;
  final String dueDate;
  final String month;

  const FeeBreakdown({
    required this.rentAmount,
    required this.messAmount,
    required this.utilityAmount,
    this.lateFee = 0.0,
    required this.dueDate,
    required this.month,
  });

  double get totalAmount => rentAmount + messAmount + utilityAmount + lateFee;
}
