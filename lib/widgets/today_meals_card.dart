import 'package:flutter/material.dart';
import '../models/resident_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TodayMealsCard extends StatelessWidget {
  final List<MealItem> meals;
  final VoidCallback onViewFullMenu;

  const TodayMealsCard({
    Key? key,
    required this.meals,
    required this.onViewFullMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Menu",
              style: AppTypography.headlineMd(color: AppColors.deepNavy).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            TextButton(
              onPressed: onViewFullMenu,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "View Weekly",
                style: AppTypography.bodyMd(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of Individual Meal Cards
        ...meals.map((meal) {
          final accentColor = _getMealColor(meal.mealName);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBECF0), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(9, 30, 66, 0.04),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Colored left border bar
                      Container(
                        width: 4,
                        color: accentColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon container with matching light background
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getMealIcon(meal.mealName),
                                  size: 20,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal.mealName,
                                      style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      meal.timing,
                                      style: AppTypography.labelSm(color: AppColors.slateGray).copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      meal.menuDetails,
                                      style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
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
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getMealColor(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFF9F1C); // Warm Orange
      case 'lunch':
        return const Color(0xFF2EC4B6); // Teal/Green
      case 'evening snacks':
      case 'snacks':
        return const Color(0xFF3A86C8); // Light Blue
      case 'dinner':
        return const Color(0xFF1D3557); // Deep Navy/Dark Blue
      default:
        return AppColors.primary;
    }
  }

  IconData _getMealIcon(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast':
        return Icons.bakery_dining_outlined; // Croissant style
      case 'lunch':
        return Icons.restaurant_menu_rounded;
      case 'evening snacks':
      case 'snacks':
        return Icons.local_cafe_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }
}
