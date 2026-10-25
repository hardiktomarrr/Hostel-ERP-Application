import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';
import 'app_text_field.dart';

class UtrSubmissionModal extends StatefulWidget {
  final double defaultAmount;
  final Function(String utr, double amount, String notes) onSubmit;

  const UtrSubmissionModal({
    Key? key,
    required this.defaultAmount,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<UtrSubmissionModal> createState() => _UtrSubmissionModalState();
}

class _UtrSubmissionModalState extends State<UtrSubmissionModal> {
  final TextEditingController _utrController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isSubmitting = false;
  String? _utrError;
  bool _fileAttached = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.defaultAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _utrController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final utr = _utrController.text.trim();
    if (utr.isEmpty || utr.length < 8) {
      setState(() {
        _utrError = "Please enter a valid 12-digit UTR/Ref Number";
      });
      return;
    }

    setState(() {
      _utrError = null;
      _isSubmitting = true;
    });

    final amount = double.tryParse(_amountController.text) ?? widget.defaultAmount;
    await widget.onSubmit(utr, amount, _notesController.text);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Submit Payment Receipt / UTR",
                style: AppTypography.headlineSm(color: AppColors.deepNavy),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.slateGray),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            "Enter the 12-digit reference number from your GPay, PhonePe, or Bank app after completing transfer.",
            style: AppTypography.bodyMd(color: AppColors.slateGray),
          ),
          const SizedBox(height: 20),

          AppTextField(
            label: "12-Digit UTR / Transaction Ref No.",
            controller: _utrController,
            hintText: "e.g., 327719823019",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.pin_outlined,
            errorText: _utrError,
          ),
          const SizedBox(height: 16),

          AppTextField(
            label: "Amount Paid (₹)",
            controller: _amountController,
            hintText: "12500",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.currency_rupee_rounded,
          ),
          const SizedBox(height: 16),

          // Upload Screenshot Box
          GestureDetector(
            onTap: () {
              setState(() {
                _fileAttached = !_fileAttached;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _fileAttached
                    ? AppColors.successEmerald.withOpacity(0.08)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _fileAttached ? AppColors.successEmerald : AppColors.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _fileAttached ? Icons.check_circle : Icons.cloud_upload_outlined,
                    color: _fileAttached ? AppColors.successEmerald : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fileAttached ? "payment_screenshot.png attached" : "Upload Payment Screenshot",
                          style: AppTypography.labelMd(
                            color: _fileAttached ? AppColors.successEmerald : AppColors.deepNavy,
                          ),
                        ),
                        Text(
                          _fileAttached ? "File ready for verification" : "JPEG, PNG or PDF (Max 5MB)",
                          style: AppTypography.labelSm(color: AppColors.slateGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          AppButton(
            text: "Submit for Verification",
            isLoading: _isSubmitting,
            onPressed: _handleSubmit,
            icon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }
}
