import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class BankUpiInfoCard extends StatelessWidget {
  final String upiId = "lakshyahostel@okicici";
  final String bankName = "HDFC Bank";
  final String accountNumber = "50100239102931";
  final String ifscCode = "HDFC0000128";
  final String accountHolder = "Lakshya's Hostel & Residency Pvt Ltd";

  const BankUpiInfoCard({Key? key}) : super(key: key);

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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "DIRECT BANK / UPI TRANSFER",
                style: AppTypography.labelSm(color: AppColors.slateGray),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // UPI Quick Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Official Hostel UPI ID",
                        style: AppTypography.labelMd(color: AppColors.slateGray),
                      ),
                      Text(
                        upiId,
                        style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: upiId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("UPI ID copied to clipboard!"),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Copy",
                          style: AppTypography.labelSm(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // NEFT / RTGS Details
          _BankDetailRow(label: "Account Name", value: accountHolder),
          const SizedBox(height: 8),
          _BankDetailRow(label: "Bank Name", value: bankName),
          const SizedBox(height: 8),
          _BankDetailRow(label: "Account Number", value: accountNumber),
          const SizedBox(height: 8),
          _BankDetailRow(label: "IFSC Code", value: ifscCode),
        ],
      ),
    );
  }
}

class _BankDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _BankDetailRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMd(color: AppColors.slateGray)),
        Text(
          value,
          style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
