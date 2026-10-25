import 'package:flutter/material.dart';
import '../controllers/payments_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/payment_history_tile.dart';
import 'payment_page.dart';

class PaymentsScreen extends StatefulWidget {
  final bool isEmbedded;
  const PaymentsScreen({Key? key, this.isEmbedded = false}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late final PaymentsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaymentsController();
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _openPaymentPage(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          controller: _controller,
        ),
      ),
    );
    if (result == true) {
      _showActionSnackBar("Payment completed successfully!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _controller.filteredRecords;

    final bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title & Subtitle
              Text(
                "Fees & Payments",
                style: AppTypography.headlineLgMobile(color: AppColors.deepNavy).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Manage your upcoming dues and view payment history.",
                style: AppTypography.bodyMd(color: AppColors.slateGray),
              ),
              const SizedBox(height: 20),

              // PENDING card (Current Rent Due)
              _buildPendingCard(context),
              const SizedBox(height: 16),

              // Upcoming September Rent Card
              _buildUpcomingCard(),
              const SizedBox(height: 24),

              // Payment History Section
              _buildHistorySection(context, records),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    if (widget.isEmbedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Lakshya's",
          style: AppTypography.headlineMd(color: AppColors.primary).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11"),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFEBECF0), height: 1),
        ),
      ),
      body: SafeArea(
        child: bodyContent,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Payments tab selected
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildPendingCard(BuildContext context) {
    final dues = _controller.currentDues;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent line (Yellow/Amber)
              Container(
                width: 5,
                color: AppColors.warningAmber,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Icon Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6), // Light warning yellow
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "PENDING",
                              style: AppTypography.labelSm(color: const Color(0xFFB76E00)).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.slateGray,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${dues.month} Rent",
                        style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "₹${dues.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}",
                        style: AppTypography.headlineLg(color: AppColors.deepNavy).copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Due by ${dues.dueDate}",
                        style: AppTypography.labelMd(color: AppColors.slateGray),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _openPaymentPage(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                        label: Text(
                          "Pay Rent Now",
                          style: AppTypography.bodyLg(color: Colors.white).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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

  Widget _buildUpcomingCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFEDEEF0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.slateGray,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "September Rent",
                  style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Est. ₹4,500",
                  style: AppTypography.labelMd(color: AppColors.slateGray),
                ),
              ],
            ),
          ),
          Text(
            "Upcoming",
            style: AppTypography.bodyMd(color: AppColors.slateGray).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, List records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Payment History",
              style: AppTypography.headlineMd(color: AppColors.deepNavy).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () => _showActionSnackBar("Downloading statement..."),
              child: Row(
                children: [
                  Text(
                    "Download Statement",
                    style: AppTypography.labelSm(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.download_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // History List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final record = records[idx];
            return PaymentHistoryTile(
              record: record,
              onDownloadReceipt: () {
                _showActionSnackBar("Downloading receipt PDF for ${record.id}...");
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // View Older Transactions Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEBECF0), width: 1),
          ),
          child: TextButton(
            onPressed: () => _showActionSnackBar("Loading older transactions..."),
            child: Text(
              "View Older Transactions",
              style: AppTypography.headlineSm(color: AppColors.primary).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showActionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
