import 'package:flutter/material.dart';
import '../models/payment_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class DuesSummaryCard extends StatelessWidget {
  final FeeBreakdown dues;
  final VoidCallback onPayOnline;
  final VoidCallback onSubmitUtr;

  const DuesSummaryCard({
    Key? key,
    required this.dues,
    required this.onPayOnline,
    required this.onSubmitUtr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "CURRENT BILLING PERIOD (${dues.month.toUpperCase()})",
                        style: AppTypography.labelSm(color: AppColors.slateGray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "UNPAID",
                  style: AppTypography.labelSm(color: const Color(0xFFB76E00)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "₹ ${dues.totalAmount.toStringAsFixed(0)}",
            style: AppTypography.headlineLg(color: AppColors.deepNavy).copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              Icon(Icons.event_outlined, size: 14, color: AppColors.slateGray),
              const SizedBox(width: 4),
              Text(
                "Payment Due by ${dues.dueDate}",
                style: AppTypography.labelMd(color: AppColors.slateGray),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 14),

          // Detailed Fee Breakdown List
          _FeeItemRow(label: "Room Rent (3 Sharing AC)", amount: dues.rentAmount),
          const SizedBox(height: 8),
          _FeeItemRow(label: "Mess & Catering Charges", amount: dues.messAmount),
          if (dues.utilityAmount > 0) ...[
            const SizedBox(height: 8),
            _FeeItemRow(label: "Electricity & Maintenance", amount: dues.utilityAmount),
          ],
          const SizedBox(height: 20),

          // CTAs
          Row(
            children: [
              Expanded(
                flex: 6,
                child: AppButton(
                  text: "Pay Online",
                  onPressed: onPayOnline,
                  icon: Icons.credit_card_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: AppButton(
                  text: "Submit UTR",
                  type: ButtonType.secondary,
                  onPressed: onSubmitUtr,
                  icon: Icons.upload_file_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeeItemRow extends StatelessWidget {
  final String label;
  final double amount;

  const _FeeItemRow({Key? key, required this.label, required this.amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMd(color: AppColors.slateGray),
        ),
        Text(
          "₹ ${amount.toStringAsFixed(0)}",
          style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
