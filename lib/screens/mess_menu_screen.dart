import 'package:flutter/material.dart';
import '../controllers/mess_menu_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/day_selector_tabs.dart';
import '../widgets/meal_category_card.dart';

class MessMenuScreen extends StatefulWidget {
  const MessMenuScreen({Key? key}) : super(key: key);

  @override
  State<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen> {
  late final MessMenuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MessMenuController();
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDayMenu = _controller.selectedDayMenu;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Weekly Mess Menu",
              style: AppTypography.headlineSm(color: AppColors.deepNavy),
            ),
            Text(
              "Current Week (${_controller.currentWeekRange})",
              style: AppTypography.labelMd(color: AppColors.slateGray),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_outlined, color: AppColors.primary),
            tooltip: "Mess Feedback",
            onPressed: () {
              _showFeedbackDialog(context);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFEBECF0), height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Day selector tabs (Mon - Sun)
            DaySelectorTabs(
              days: _controller.weeklyMenu,
              selectedIndex: _controller.selectedDayIndex,
              onSelectDay: (idx) => _controller.selectDay(idx),
            ),
            const SizedBox(height: 16),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informational Banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.eco_outlined,
                                color: AppColors.successEmerald,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Going out for dinner or home? Mark 'Skip Meal' in advance to help reduce hostel kitchen food waste.",
                                  style: AppTypography.bodyMd(color: AppColors.deepNavy),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section Title for Selected Day
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${currentDayMenu.dayName}'s Menu ",
                                    style: AppTypography.headlineMd(color: AppColors.deepNavy),
                                  ),
                                  TextSpan(
                                    text: "(${currentDayMenu.dateStr})",
                                    style: AppTypography.bodyLg(color: AppColors.slateGray),
                                  ),
                                ],
                              ),
                            ),
                            if (currentDayMenu.isToday)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.successEmerald.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "TODAY'S SCHEDULE",
                                  style: AppTypography.labelSm(color: AppColors.successEmerald),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Meals Grid / List
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth >= 768;

                            final mealCards = [
                              MealCategoryCard(
                                meal: currentDayMenu.breakfast,
                                isSkipped: _controller.isMealSkipped("${currentDayMenu.dayName}_breakfast"),
                                onToggleSkip: () => _controller.toggleSkipMeal("${currentDayMenu.dayName}_breakfast"),
                              ),
                              MealCategoryCard(
                                meal: currentDayMenu.lunch,
                                isSkipped: _controller.isMealSkipped("${currentDayMenu.dayName}_lunch"),
                                onToggleSkip: () => _controller.toggleSkipMeal("${currentDayMenu.dayName}_lunch"),
                              ),
                              MealCategoryCard(
                                meal: currentDayMenu.snacks,
                                isSkipped: _controller.isMealSkipped("${currentDayMenu.dayName}_snacks"),
                                onToggleSkip: () => _controller.toggleSkipMeal("${currentDayMenu.dayName}_snacks"),
                              ),
                              MealCategoryCard(
                                meal: currentDayMenu.dinner,
                                isSkipped: _controller.isMealSkipped("${currentDayMenu.dayName}_dinner"),
                                onToggleSkip: () => _controller.toggleSkipMeal("${currentDayMenu.dayName}_dinner"),
                              ),
                            ];

                            if (isDesktop) {
                              return GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                                children: mealCards,
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: mealCards.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (_, idx) => mealCards[idx],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Mess Menu tab selected
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Mess Meal Feedback",
          style: AppTypography.headlineSm(color: AppColors.deepNavy),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How was today's food quality & taste?",
              style: AppTypography.bodyMd(color: AppColors.slateGray),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _RatingEmoji(emoji: "😞", label: "Poor"),
                _RatingEmoji(emoji: "😐", label: "Average"),
                _RatingEmoji(emoji: "😋", label: "Delicious"),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: "Add optional comments for warden...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: AppTypography.bodyMd(color: AppColors.slateGray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Thank you! Your feedback has been sent to the Mess Warden."),
                  backgroundColor: AppColors.successEmerald,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            child: const Text("Submit Feedback"),
          ),
        ],
      ),
    );
  }
}

class _RatingEmoji extends StatelessWidget {
  final String emoji;
  final String label;

  const _RatingEmoji({Key? key, required this.emoji, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelSm(color: AppColors.slateGray)),
      ],
    );
  }
}
