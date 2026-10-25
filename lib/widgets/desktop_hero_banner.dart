import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DesktopHeroBanner extends StatelessWidget {
  const DesktopHeroBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepNavy,
            Color(0xFF003D9B),
            AppColors.primary,
          ],
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Brand Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lakshya's Hostel",
                    style: AppTypography.headlineSm(color: Colors.white),
                  ),
                  Text(
                    "STRUCTURE ERP SYSTEM",
                    style: AppTypography.labelSm(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center Graphic Illustration & Value Proposition
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successEmerald.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.successEmerald.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.successEmerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "LIVE HOSTEL ERP PLATFORM",
                      style: AppTypography.labelSm(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Modern, Seamless\nHostel & Flat Management.",
                style: AppTypography.headlineLg(color: Colors.white).copyWith(
                  height: 1.2,
                  fontSize: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Access real-time mess menus, payment ledgers, automated cab schedules, and instant maintenance tickets in one place.",
                style: AppTypography.bodyLg(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 36),

              // Feature Highlights
              _FeatureTile(
                icon: Icons.restaurant_menu_rounded,
                title: "Daily Mess & Meals Tracker",
                subtitle: "View today's meals and provide instant feedback.",
              ),
              const SizedBox(height: 16),
              _FeatureTile(
                icon: Icons.account_balance_wallet_outlined,
                title: "Transparent Dues & Ledger",
                subtitle: "Track invoices, submit UTR receipts, and verify payments.",
              ),
              const SizedBox(height: 16),
              _FeatureTile(
                icon: Icons.support_agent_rounded,
                title: "24/7 Resident Support",
                subtitle: "Submit plumbing, wifi, or room maintenance tickets easily.",
              ),
            ],
          ),

          // Footer Copyright / Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "© 2026 Lakshya's Hostel ERP. All rights reserved.",
                style: AppTypography.labelMd(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: Colors.white.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    "Secure 256-bit Encryption",
                    style: AppTypography.labelSm(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineSm(color: Colors.white),
              ),
              Text(
                subtitle,
                style: AppTypography.bodyMd(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
