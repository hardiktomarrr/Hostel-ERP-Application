import 'package:flutter/material.dart';
import '../models/mess_menu_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class MealCategoryCard extends StatelessWidget {
  final MealSlot meal;
  final bool isSkipped;
  final VoidCallback onToggleSkip;

  const MealCategoryCard({
    Key? key,
    required this.meal,
    required this.isSkipped,
    required this.onToggleSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSkipped ? AppColors.background : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: meal.isSpecial
              ? AppColors.primary.withOpacity(0.4)
              : const Color(0xFFEBECF0),
          width: meal.isSpecial ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, isSkipped ? 0.02 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: meal.isSpecial
                      ? AppColors.warningAmber.withOpacity(0.2)
                      : AppColors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  meal.icon,
                  size: 20,
                  color: meal.isSpecial
                      ? const Color(0xFFB76E00)
                      : AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          meal.name,
                          style: AppTypography.headlineSm(
                            color: isSkipped ? AppColors.slateGray : AppColors.deepNavy,
                          ),
                        ),
                        if (meal.isSpecial) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warningAmber.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 12, color: Color(0xFFB76E00)),
                                const SizedBox(width: 4),
                                Text(
                                  "SPECIAL",
                                  style: AppTypography.labelSm(color: const Color(0xFFB76E00)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.schedule_outlined, size: 13, color: AppColors.slateGray),
                        const SizedBox(width: 4),
                        Text(
                          meal.timing,
                          style: AppTypography.labelMd(color: AppColors.slateGray),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "•  ${meal.calories}",
                          style: AppTypography.labelMd(color: AppColors.slateGray.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dish Items Wrap / Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: meal.items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSkipped
                      ? AppColors.surfaceContainer
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE1E2E4), width: 1),
                ),
                child: Text(
                  item,
                  style: AppTypography.bodyMd(
                    color: isSkipped ? AppColors.slateGray.withOpacity(0.6) : AppColors.deepNavy,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 12),

          // Bottom Action: Skip Meal Switch / Feedback
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isSkipped ? Icons.do_not_disturb_on_outlined : Icons.check_circle_outline,
                    size: 16,
                    color: isSkipped ? AppColors.errorRuby : AppColors.successEmerald,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSkipped ? "You are skipping this meal" : "Attending meal",
                    style: AppTypography.labelMd(
                      color: isSkipped ? AppColors.errorRuby : AppColors.successEmerald,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: onToggleSkip,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isSkipped ? AppColors.primary : AppColors.slateGray,
                  side: BorderSide(
                    color: isSkipped ? AppColors.primary : AppColors.outlineVariant,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: Icon(
                  isSkipped ? Icons.undo_rounded : Icons.block_rounded,
                  size: 14,
                ),
                label: Text(
                  isSkipped ? "Undo Skip" : "Skip Meal",
                  style: AppTypography.labelSm(
                    color: isSkipped ? AppColors.primary : AppColors.slateGray,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
