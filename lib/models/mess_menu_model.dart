import 'package:flutter/material.dart';

class MealSlot {
  final String name;
  final String timing;
  final List<String> items;
  final IconData icon;
  final bool isSpecial;
  final String calories;

  const MealSlot({
    required this.name,
    required this.timing,
    required this.items,
    required this.icon,
    this.isSpecial = false,
    required this.calories,
  });
}

class DayMenu {
  final String dayName;
  final String shortDay;
  final String dateStr;
  final bool isToday;
  final MealSlot breakfast;
  final MealSlot lunch;
  final MealSlot snacks;
  final MealSlot dinner;

  const DayMenu({
    required this.dayName,
    required this.shortDay,
    required this.dateStr,
    this.isToday = false,
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });
}
