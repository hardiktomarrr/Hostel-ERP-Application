import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/payments_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PaymentPage extends StatefulWidget {
  final PaymentsController controller;

  const PaymentPage({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _utrController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isFileUploaded = false;
  bool _isSubmitting = false;
  String? _utrError;

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return "$month/$day/$year";
  }

  void _copyToClipboard() {
    Clipboard.setData(const ClipboardData(text: "hostel@upi"));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("UPI ID copied to clipboard!"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleSubmit() async {
    final utr = _utrController.text.trim();
    if (utr.isEmpty) {
      setState(() {
        _utrError = "Please enter UTR / Transaction ID";
      });
      return;
    }
    if (utr.length < 8) {
      setState(() {
        _utrError = "Please enter a valid Transaction ID (min 8 chars)";
      });
      return;
    }

    setState(() {
      _utrError = null;
      _isSubmitting = true;
    });

    // Submit via controller
    final success = await widget.controller.submitUtr(
      utrNumber: utr,
      amount: widget.controller.currentDues.totalAmount,
      notes: "",
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogCtx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successEmerald.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.successEmerald,
                size: 40,
              ),
            ),
            title: Text(
              "Submitted Successfully!",
              style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Your payment verification request of ₹${widget.controller.currentDues.totalAmount.toStringAsFixed(0)} has been submitted. It will be verified by the manager shortly.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(color: AppColors.slateGray),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Return success to parent screen
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Done"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit verification. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dues = widget.controller.currentDues;
    final amountText = "₹ ${dues.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Pay using UPI",
          style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFEBECF0), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instruction label
                  Center(
                    child: Text(
                      "Pay ₹${dues.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")} externally and enter UTR below.",
                      style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR Code Card
                  _buildQrCard(),
                  const SizedBox(height: 32),

                  // Section Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFEBECF0), thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "PAYMENT DETAILS",
                          style: AppTypography.labelMd(color: AppColors.slateGray).copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFEBECF0), thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Amount Paid Field (Disabled)
                  Text(
                    "Amount Paid",
                    style: AppTypography.labelSm(color: AppColors.deepNavy).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEBECF0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          amountText,
                          style: AppTypography.bodyLg(color: AppColors.deepNavy).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.successEmerald,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // UTR / Transaction ID Field
                  Text(
                    "UTR / Transaction ID *",
                    style: AppTypography.labelSm(color: AppColors.deepNavy).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _utrController,
                    keyboardType: TextInputType.text,
                    style: AppTypography.bodyLg(color: AppColors.deepNavy),
                    decoration: InputDecoration(
                      hintText: "e.g. 301234567890",
                      hintStyle: AppTypography.bodyLg(color: AppColors.slateGray.withOpacity(0.6)),
                      errorText: _utrError,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFEBECF0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFEBECF0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Date Field
                  Text(
                    "Payment Date *",
                    style: AppTypography.labelSm(color: AppColors.deepNavy).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectPaymentDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEBECF0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(_selectedDate),
                            style: AppTypography.bodyLg(color: AppColors.deepNavy),
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.slateGray,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Screenshot Upload Box (Optional)
                  Text(
                    "Screenshot Upload (Optional)",
                    style: AppTypography.labelSm(color: AppColors.deepNavy).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildScreenshotUpload(),
                  const SizedBox(height: 36),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0049B0), // Dark blue matching button in mockup
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSubmitting ? "Submitting..." : "Submit for Verification",
                          style: AppTypography.bodyLg(color: Colors.white).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left blue accent line
              Container(
                width: 5,
                color: const Color(0xFF0049B0),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // QR Code Container with custom dotted border
                      CustomPaint(
                        painter: DashedRectPainter(
                          color: const Color(0xFFD0D5DD),
                          strokeWidth: 1.5,
                          gap: 4,
                        ),
                        child: Container(
                          width: 170,
                          height: 170,
                          padding: const EdgeInsets.all(16),
                          child: _buildSimulatedQrCode(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "UPI ID",
                        style: AppTypography.labelSm(color: AppColors.slateGray),
                      ),
                      const SizedBox(height: 8),

                      // Copyable UPI ID box
                      InkWell(
                        onTap: _copyToClipboard,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F5F7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFEBECF0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "hostel@upi",
                                style: AppTypography.bodyLg(color: AppColors.deepNavy).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.copy_rounded,
                                color: AppColors.slateGray,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotUpload() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFileUploaded = !_isFileUploaded;
        });
      },
      child: CustomPaint(
        painter: DashedRectPainter(
          color: _isFileUploaded ? AppColors.successEmerald : const Color(0xFFC4C9D3),
          strokeWidth: 1.5,
          gap: 4,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: _isFileUploaded 
                ? AppColors.successEmerald.withOpacity(0.04) 
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                _isFileUploaded ? Icons.task_alt_rounded : Icons.add_photo_alternate_outlined,
                color: _isFileUploaded ? AppColors.successEmerald : AppColors.slateGray,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                _isFileUploaded ? "payment_receipt_screenshot.png" : "Add Photo",
                style: AppTypography.bodyMd(
                  color: _isFileUploaded ? AppColors.successEmerald : AppColors.slateGray,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatedQrCode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFinderPattern(),
            Column(
              children: [
                Row(
                  children: [
                    _buildQrPixel(true),
                    _buildQrPixel(false),
                    _buildQrPixel(true),
                  ],
                ),
                Row(
                  children: [
                    _buildQrPixel(false),
                    _buildQrPixel(true),
                    _buildQrPixel(false),
                  ],
                ),
              ],
            ),
            _buildFinderPattern(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    _buildQrPixel(true),
                    _buildQrPixel(true),
                    _buildQrPixel(false),
                  ],
                ),
                Row(
                  children: [
                    _buildQrPixel(false),
                    _buildQrPixel(true),
                    _buildQrPixel(true),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                _buildQrPixel(true),
                _buildQrPixel(true),
                _buildQrPixel(true),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    _buildQrPixel(false),
                    _buildQrPixel(true),
                    _buildQrPixel(false),
                  ],
                ),
                Row(
                  children: [
                    _buildQrPixel(true),
                    _buildQrPixel(false),
                    _buildQrPixel(true),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFinderPattern(),
            Column(
              children: [
                Row(
                  children: [
                    _buildQrPixel(true),
                    _buildQrPixel(false),
                    _buildQrPixel(true),
                  ],
                ),
                Row(
                  children: [
                    _buildQrPixel(false),
                    _buildQrPixel(true),
                    _buildQrPixel(false),
                  ],
                ),
              ],
            ),
            _buildQrPixel(true),
          ],
        ),
      ],
    );
  }

  Widget _buildFinderPattern() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF333E52), width: 5),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF333E52),
          shape: BoxShape.rectangle,
        ),
      ),
    );
  }

  Widget _buildQrPixel(bool active) {
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.all(0.8),
      color: active ? const Color(0xFF333E52) : Colors.transparent,
    );
  }

  void _selectPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    ));

    final Path dashedPath = Path();
    double distance = 0.0;
    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
