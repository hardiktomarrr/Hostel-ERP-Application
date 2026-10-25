import 'package:flutter/material.dart';
import '../models/resident_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AnnouncementsCard extends StatelessWidget {
  final List<Announcement> announcements;

  const AnnouncementsCard({
    Key? key,
    required this.announcements,
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "RECENT ANNOUNCEMENTS",
                style: AppTypography.labelSm(color: AppColors.slateGray),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcements.length,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.surfaceContainer,
              height: 20,
            ),
            itemBuilder: (context, index) {
              final item = announcements[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.headlineSm(color: AppColors.deepNavy),
                        ),
                      ),
                      if (item.isImportant)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorRuby.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "NOTICE",
                            style: AppTypography.labelSm(color: AppColors.errorRuby),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: AppTypography.bodyMd(color: AppColors.slateGray),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.timeAgo,
                    style: AppTypography.labelMd(color: AppColors.slateGray.withOpacity(0.7)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
