import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class SubmitPaymentConfirmationScreen extends StatefulWidget {
  final double defaultAmount;
  final String billingPeriod;

  const SubmitPaymentConfirmationScreen({
    Key? key,
    this.defaultAmount = 12500.0,
    this.billingPeriod = "November 2023 Rent & Mess Fee",
  }) : super(key: key);

  @override
  State<SubmitPaymentConfirmationScreen> createState() =>
      _SubmitPaymentConfirmationScreenState();
}

class _SubmitPaymentConfirmationScreenState
    extends State<SubmitPaymentConfirmationScreen> {
  final TextEditingController _utrController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _utrError;
  bool _isFileUploaded = false;
  bool _isSubmitting = false;
  bool _isSubmittedSuccess = false;
  String _referenceId = "";

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
        _utrError = "Please enter a valid 12-digit UTR/Reference Number";
      });
      return;
    }

    setState(() {
      _utrError = null;
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 1400));

    setState(() {
      _isSubmitting = false;
      _isSubmittedSuccess = true;
      _referenceId = "VER-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Submit Payment Confirmation",
              style: AppTypography.headlineSm(color: AppColors.deepNavy),
            ),
            Text(
              "Manual UPI & Bank Transfer Verification",
              style: AppTypography.labelMd(color: AppColors.slateGray),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFEBECF0), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _isSubmittedSuccess
                  ? _buildSuccessView()
                  : _buildConfirmationForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Amount Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.billingPeriod,
                      style: AppTypography.labelMd(color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "₹ ${widget.defaultAmount.toStringAsFixed(0)}",
                      style: AppTypography.headlineLg(color: AppColors.deepNavy).copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick UPI Instructions Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEBECF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Transfer Instructions",
                    style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Pay ₹${widget.defaultAmount.toStringAsFixed(0)} externally via GPay, PhonePe, Paytm or NetBanking to the official hostel UPI ID below and paste your 12-digit UTR reference number.",
                style: AppTypography.bodyMd(color: AppColors.slateGray),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("UPI ID: ", style: AppTypography.labelMd(color: AppColors.slateGray)),
                      Text(
                        "lakshyahostel@okicici",
                        style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: "lakshyahostel@okicici"));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("UPI ID copied!"),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 13),
                    label: const Text("Copy UPI"),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Verification Form Inputs
        Text(
          "Enter Payment Reference Details",
          style: AppTypography.headlineSm(color: AppColors.deepNavy),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: "12-Digit UTR / Transaction Ref No. *",
          controller: _utrController,
          hintText: "e.g. 327719823019",
          keyboardType: TextInputType.number,
          prefixIcon: Icons.tag_rounded,
          errorText: _utrError,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: "Amount Paid (₹) *",
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Date",
                    style: AppTypography.labelSm(color: AppColors.deepNavy),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEBECF0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                            style: AppTypography.bodyMd(color: AppColors.deepNavy),
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.slateGray),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Attachment Box
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Upload Screenshot or Bank Receipt (Optional)",
              style: AppTypography.labelSm(color: AppColors.deepNavy),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isFileUploaded = !_isFileUploaded;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isFileUploaded
                      ? AppColors.successEmerald.withOpacity(0.08)
                      : AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isFileUploaded ? AppColors.successEmerald : const Color(0xFFEBECF0),
                    width: _isFileUploaded ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isFileUploaded ? Icons.task_alt_rounded : Icons.cloud_upload_outlined,
                      size: 32,
                      color: _isFileUploaded ? AppColors.successEmerald : AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isFileUploaded
                          ? "payment_receipt_screenshot.png (Selected)"
                          : "Tap to select screenshot or PDF file",
                      style: AppTypography.labelMd(
                        color: _isFileUploaded ? AppColors.successEmerald : AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isFileUploaded
                          ? "Tap again to change attachment"
                          : "Supports JPG, PNG, PDF up to 10MB",
                      style: AppTypography.labelSm(color: AppColors.slateGray),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: "Additional Notes / Comments (Optional)",
          controller: _notesController,
          hintText: "Add any note for the hostel accountant...",
          prefixIcon: Icons.notes_rounded,
        ),
        const SizedBox(height: 28),

        AppButton(
          text: "Submit Payment Confirmation",
          isLoading: _isSubmitting,
          onPressed: _handleSubmit,
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBECF0)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successEmerald.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: AppColors.successEmerald,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Payment Confirmation Submitted!",
            style: AppTypography.headlineLg(color: AppColors.deepNavy),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Your UTR details have been received. The warden will verify the bank deposit within 1-2 business hours.",
            style: AppTypography.bodyMd(color: AppColors.slateGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _SummaryDetailRow(label: "Verification ID", value: _referenceId),
                const SizedBox(height: 8),
                _SummaryDetailRow(label: "UTR Reference", value: _utrController.text),
                const SizedBox(height: 8),
                _SummaryDetailRow(label: "Amount Paid", value: "₹ ${_amountController.text}"),
                const SizedBox(height: 8),
                _SummaryDetailRow(label: "Current Status", value: "VERIFYING", valueColor: const Color(0xFFB76E00)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          AppButton(
            text: "Return to Payment Ledger",
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icons.arrow_back_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryDetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.labelMd(color: AppColors.slateGray)),
        Text(
          value,
          style: AppTypography.headlineSm(color: valueColor ?? AppColors.deepNavy).copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
