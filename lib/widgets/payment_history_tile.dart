import 'package:flutter/material.dart';
import '../models/payment_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PaymentHistoryTile extends StatelessWidget {
  final PaymentRecord record;
  final VoidCallback onDownloadReceipt;

  const PaymentHistoryTile({
    Key? key,
    required this.record,
    required this.onDownloadReceipt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(record.status);
    final statusBgColor = _getStatusBgColor(record.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left status accent vertical bar
              Container(
                width: 5,
                color: statusColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Circle Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(record.status),
                          size: 20,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Details Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              record.title,
                              style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Subtitle (Date & UTR)
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: AppColors.slateGray,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  record.date,
                                  style: AppTypography.labelMd(color: AppColors.slateGray),
                                ),
                                if (record.utrNumber.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      "•",
                                      style: TextStyle(
                                        color: AppColors.slateGray.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "UTR: ${record.utrNumber}",
                                      style: AppTypography.labelMd(color: AppColors.slateGray),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Bottom Row (Amount & Status Badge)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${record.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}",
                                  style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getStatusText(record.status),
                                    style: AppTypography.labelSm(color: statusColor).copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.successEmerald;
      case PaymentStatus.verifying:
        return const Color(0xFFB76E00);
      case PaymentStatus.pending:
      case PaymentStatus.failed:
        return AppColors.errorRuby;
    }
  }

  Color _getStatusBgColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Color(0xFFE3FCEF); // soft emerald
      case PaymentStatus.verifying:
        return const Color(0xFFFFF9E6); // soft amber
      case PaymentStatus.pending:
      case PaymentStatus.failed:
        return const Color(0xFFFFEBE6); // soft ruby
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Icons.check_rounded;
      case PaymentStatus.verifying:
        return Icons.hourglass_empty_rounded;
      case PaymentStatus.pending:
      case PaymentStatus.failed:
        return Icons.close_rounded;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return "APPROVED";
      case PaymentStatus.verifying:
        return "VERIFYING";
      case PaymentStatus.pending:
        return "PENDING";
      case PaymentStatus.failed:
        return "FAILED";
    }
  }
}
