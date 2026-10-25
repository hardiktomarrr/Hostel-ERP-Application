import 'package:flutter/material.dart';
import '../models/resident_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ResidentDuesCard extends StatelessWidget {
  final DueInfo dues;
  final VoidCallback onPayDues;

  const ResidentDuesCard({
    Key? key,
    required this.dues,
    required this.onPayDues,
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
            color: Color.fromRGBO(9, 30, 66, 0.05),
            blurRadius: 16,
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
              // Red/orange vertical accent indicator bar matching image
              Container(
                width: 4,
                color: const Color(0xFFFF5252),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFF5252),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Outstanding Dues",
                            style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "₹ ${dues.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                        style: AppTypography.headlineLg(color: AppColors.deepNavy).copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Due by ${dues.dueDate}",
                        style: AppTypography.labelMd(color: AppColors.slateGray).copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: onPayDues,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C46A0), // Deep blue from image
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Pay Now",
                            style: AppTypography.headlineSm(color: Colors.white).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
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
}
