import 'package:flutter/material.dart';
import '../models/payment_data.dart';

class PaymentsController extends ChangeNotifier {
  int _selectedFilterIndex = 0;
  bool _isSubmittingUtr = false;

  int get selectedFilterIndex => _selectedFilterIndex;
  bool get isSubmittingUtr => _isSubmittingUtr;

  final FeeBreakdown currentDues = const FeeBreakdown(
    rentAmount: 4500.0,
    messAmount: 0.0,
    utilityAmount: 0.0,
    dueDate: "Aug 5, 2026",
    month: "August 2026",
  );

  final List<PaymentRecord> _records = [
    const PaymentRecord(
      id: "REC-2026-0701",
      title: "July 2026 Rent",
      amount: 4500.0,
      date: "Jul 02, 2026",
      method: "UPI",
      utrNumber: "HDFC893475923",
      status: PaymentStatus.paid,
      receiptUrl: "https://example.com/receipt/jul2026.pdf",
    ),
    const PaymentRecord(
      id: "REC-2026-0601",
      title: "June 2026 Rent",
      amount: 4500.0,
      date: "Jun 04, 2026",
      method: "UPI",
      utrNumber: "SBI928374610",
      status: PaymentStatus.paid,
      receiptUrl: "https://example.com/receipt/jun2026.pdf",
    ),
    const PaymentRecord(
      id: "REC-2026-0501",
      title: "May 2026 Rent",
      amount: 4500.0,
      date: "May 01, 2026",
      method: "UPI",
      utrNumber: "ICIC74639201",
      status: PaymentStatus.paid,
      receiptUrl: "https://example.com/receipt/may2026.pdf",
    ),
  ];

  List<PaymentRecord> get filteredRecords {
    if (_selectedFilterIndex == 1) {
      return _records.where((r) => r.status == PaymentStatus.paid).toList();
    } else if (_selectedFilterIndex == 2) {
      return _records.where((r) => r.status == PaymentStatus.verifying || r.status == PaymentStatus.pending).toList();
    }
    return _records;
  }

  void setFilterIndex(int index) {
    if (_selectedFilterIndex != index) {
      _selectedFilterIndex = index;
      notifyListeners();
    }
  }

  Future<bool> submitUtr({required String utrNumber, required double amount, required String notes}) async {
    _isSubmittingUtr = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final newRecord = PaymentRecord(
      id: "REC-2026-${_records.length + 1000}",
      title: "August 2026 Rent Payment (Pending Verification)",
      amount: amount,
      date: "Today",
      method: "Manual UTR Submission",
      utrNumber: utrNumber,
      status: PaymentStatus.verifying,
      receiptUrl: "",
    );

    _records.insert(0, newRecord);
    _isSubmittingUtr = false;
    notifyListeners();
    return true;
  }
}
