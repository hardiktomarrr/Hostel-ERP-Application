import 'package:flutter/material.dart';
import '../models/mess_menu_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DaySelectorTabs extends StatelessWidget {
  final List<DayMenu> days;
  final int selectedIndex;
  final ValueChanged<int> onSelectDay;

  const DaySelectorTabs({
    Key? key,
    required this.days,
    required this.selectedIndex,
    required this.onSelectDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Material(
                color: isSelected ? AppColors.primary : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                elevation: isSelected ? 4 : 0,
                shadowColor: const Color.fromRGBO(9, 30, 66, 0.12),
                child: InkWell(
                  onTap: () => onSelectDay(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 76,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? null
                          : Border.all(color: const Color(0xFFEBECF0), width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (day.isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.25)
                                  : AppColors.primaryContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "TODAY",
                              style: AppTypography.labelSm(
                                color: isSelected ? Colors.white : AppColors.primaryDark,
                              ).copyWith(fontSize: 9),
                            ),
                          )
                        else
                          Text(
                            day.shortDay.toUpperCase(),
                            style: AppTypography.labelSm(
                              color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.slateGray,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          day.dateStr.split(' ').last,
                          style: AppTypography.headlineSm(
                            color: isSelected ? Colors.white : AppColors.deepNavy,
                          ).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
