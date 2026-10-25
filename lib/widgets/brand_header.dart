import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class BrandHeader extends StatelessWidget {
  final bool isCompact;

  const BrandHeader({
    Key? key,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Icon Badge
        Container(
          width: isCompact ? 52 : 64,
          height: isCompact ? 52 : 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(9, 30, 66, 0.12),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.apartment_rounded,
            size: isCompact ? 28 : 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        // App Name & Branding
        Text(
          "Lakshya's Hostel",
          style: isCompact
              ? AppTypography.headlineMd()
              : AppTypography.headlineLgMobile(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "STRUCTURE ERP",
                style: AppTypography.labelSm(color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Management Portal",
              style: AppTypography.bodyMd(color: AppColors.slateGray),
            ),
          ],
        ),
      ],
    );
  }
}
