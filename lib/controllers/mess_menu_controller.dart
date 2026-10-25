import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mess_menu_model.dart';

class MessMenuController extends ChangeNotifier {
  int _selectedDayIndex = DateTime.now().weekday - 1;
  final Map<String, bool> _skippedMeals = {};
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _menuSubscription;
  List<DayMenu> _weeklyMenu = [];

  int get selectedDayIndex => _selectedDayIndex;
  bool get isLoading => _isLoading;

  List<DayMenu> get weeklyMenu => _weeklyMenu;
  DayMenu get selectedDayMenu => weeklyMenu[_selectedDayIndex];

  String get currentWeekRange {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return "${_formatDate(monday)} - ${_formatDate(sunday)}";
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}";
  }

  String _getDayNameOfToday() {
    const weekdaysMap = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return weekdaysMap[DateTime.now().weekday] ?? 'Wednesday';
  }

  String _getFormattedDateForDay(int weekdayIndex) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final targetDate = monday.add(Duration(days: weekdayIndex - 1));
    return _formatDate(targetDate);
  }

  int _getDayIndex(String dayName) {
    const dayIndices = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };
    return dayIndices[dayName] ?? 1;
  }

  MessMenuController() {
    _initWeeklyMenuWithDynamicDates();
    _loadMenu();
  }

  void _initWeeklyMenuWithDynamicDates() {
    final todayName = _getDayNameOfToday();
    _weeklyMenu = [];
    for (int i = 0; i < _defaultWeeklyMenu.length; i++) {
      final defaultDay = _defaultWeeklyMenu[i];
      final dynamicDateStr = _getFormattedDateForDay(i + 1);
      _weeklyMenu.add(DayMenu(
        dayName: defaultDay.dayName,
        shortDay: defaultDay.shortDay,
        dateStr: dynamicDateStr,
        isToday: defaultDay.dayName == todayName,
        breakfast: defaultDay.breakfast,
        lunch: defaultDay.lunch,
        snacks: defaultDay.snacks,
        dinner: defaultDay.dinner,
      ));
    }
  }

  @override
  void dispose() {
    _menuSubscription?.cancel();
    super.dispose();
  }

  bool isMealSkipped(String mealKey) => _skippedMeals[mealKey] ?? false;

  void selectDay(int index) {
    if (_selectedDayIndex != index) {
      _selectedDayIndex = index;
      notifyListeners();
    }
  }

  void toggleSkipMeal(String mealKey) {
    _skippedMeals[mealKey] = !(_skippedMeals[mealKey] ?? false);
    notifyListeners();
  }

  void _loadMenu() {
    _menuSubscription =
        _firestore.collection('mess_menu').snapshots().listen((snapshot) {
      final todayName = _getDayNameOfToday();

      if (snapshot.docs.isEmpty) {
        _initWeeklyMenuWithDynamicDates();
        notifyListeners();
        return;
      }

      final Map<String, DayMenu> fetchedMenus = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dayName = doc.id; // Monday, Tuesday, etc.

        // Find index of day (Monday = 1, Tuesday = 2, ...)
        final dayIndex = _getDayIndex(dayName);
        final dynamicDateStr = _getFormattedDateForDay(dayIndex);

        // Find default menu for this day to preserve local metadata
        final defaultDay = _defaultWeeklyMenu.firstWhere(
          (d) => d.dayName == dayName,
          orElse: () => _defaultWeeklyMenu[0],
        );

        fetchedMenus[dayName] = DayMenu(
          dayName: defaultDay.dayName,
          shortDay: defaultDay.shortDay,
          dateStr: dynamicDateStr,
          isToday: defaultDay.dayName == todayName,
          breakfast: MealSlot(
            name: defaultDay.breakfast.name,
            timing: defaultDay.breakfast.timing,
            items: _parseItems(data['breakfast'] ?? defaultDay.breakfast.items),
            icon: defaultDay.breakfast.icon,
            calories: defaultDay.breakfast.calories,
            isSpecial: defaultDay.breakfast.isSpecial,
          ),
          lunch: MealSlot(
            name: defaultDay.lunch.name,
            timing: defaultDay.lunch.timing,
            items: _parseItems(data['lunch'] ?? defaultDay.lunch.items),
            icon: defaultDay.lunch.icon,
            calories: defaultDay.lunch.calories,
            isSpecial: defaultDay.lunch.isSpecial,
          ),
          snacks: MealSlot(
            name: defaultDay.snacks.name,
            timing: defaultDay.snacks.timing,
            items: _parseItems(data['snacks'] ?? defaultDay.snacks.items),
            icon: defaultDay.snacks.icon,
            calories: defaultDay.snacks.calories,
            isSpecial: defaultDay.snacks.isSpecial,
          ),
          dinner: MealSlot(
            name: defaultDay.dinner.name,
            timing: defaultDay.dinner.timing,
            items: _parseItems(data['dinner'] ?? defaultDay.dinner.items),
            icon: defaultDay.dinner.icon,
            calories: defaultDay.dinner.calories,
            isSpecial: defaultDay.dinner.isSpecial,
          ),
        );
      }

      // Rebuild weekly menu in correct order (Monday to Sunday)
      _weeklyMenu = [];
      for (int i = 0; i < _defaultWeeklyMenu.length; i++) {
        final defaultDay = _defaultWeeklyMenu[i];
        final fetched = fetchedMenus[defaultDay.dayName];
        if (fetched != null) {
          _weeklyMenu.add(fetched);
        } else {
          final dynamicDateStr = _getFormattedDateForDay(i + 1);
          _weeklyMenu.add(DayMenu(
            dayName: defaultDay.dayName,
            shortDay: defaultDay.shortDay,
            dateStr: dynamicDateStr,
            isToday: defaultDay.dayName == todayName,
            breakfast: defaultDay.breakfast,
            lunch: defaultDay.lunch,
            snacks: defaultDay.snacks,
            dinner: defaultDay.dinner,
          ));
        }
      }

      notifyListeners();
    });
  }

  List<String> _parseItems(Object? value) {
    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    final itemText = value?.toString() ?? '';
    if (itemText.isEmpty) return [];
    // Accept the original comma-separated schema as well, so existing menu
    // documents continue to display while admins move to item arrays.
    return itemText
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static const List<DayMenu> _defaultWeeklyMenu = [
    DayMenu(
      dayName: "Monday",
      shortDay: "Mon",
      dateStr: "Oct 23",
      breakfast: MealSlot(
        name: "Breakfast",
        timing: "08:00 AM - 09:30 AM",
        items: [
          "Idli Sambhar",
          "Coconut Chutney",
          "Bread & Butter",
          "Tea / Coffee"
        ],
        icon: Icons.free_breakfast_outlined,
        calories: "380 kcal",
      ),
      lunch: MealSlot(
        name: "Lunch",
        timing: "12:30 PM - 02:00 PM",
        items: [
          "Rajma Masala",
          "Steamed Rice",
          "Mix Veg Dry",
          "Chapati",
          "Curd"
        ],
        icon: Icons.lunch_dining_outlined,
        calories: "650 kcal",
      ),
      snacks: MealSlot(
        name: "Snacks",
        timing: "05:00 PM - 06:00 PM",
        items: ["Poha", "Sev & Lemon", "Masala Chai"],
        icon: Icons.local_cafe_outlined,
        calories: "220 kcal",
      ),
      dinner: MealSlot(
        name: "Dinner",
        timing: "08:00 PM - 09:30 PM",
        items: [
          "Paneer Butter Masala",
          "Dal Fry",
          "Tandoori Roti",
          "Jeera Rice",
          "Kheer"
        ],
        icon: Icons.dinner_dining_outlined,
        isSpecial: true,
        calories: "720 kcal",
      ),
    ),
    DayMenu(
      dayName: "Tuesday",
      shortDay: "Tue",
      dateStr: "Oct 24",
      breakfast: MealSlot(
        name: "Breakfast",
        timing: "08:00 AM - 09:30 AM",
        items: ["Puri Bhaji", "Sprouted Moong Salad", "Tea / Coffee"],
        icon: Icons.free_breakfast_outlined,
        calories: "450 kcal",
      ),
      lunch: MealSlot(
        name: "Lunch",
        timing: "12:30 PM - 02:00 PM",
        items: ["Kadhi Pakoda", "Rice", "Aloo Gobi", "Chapati", "Pickle"],
        icon: Icons.lunch_dining_outlined,
        calories: "610 kcal",
      ),
      snacks: MealSlot(
        name: "Snacks",
        timing: "05:00 PM - 06:00 PM",
        items: ["Veg Sandwich", "Tomato Ketchup", "Cold Coffee"],
        icon: Icons.local_cafe_outlined,
        calories: "280 kcal",
      ),
      dinner: MealSlot(
        name: "Dinner",
        timing: "08:00 PM - 09:30 PM",
        items: [
          "Dal Tadka",
          "Bhindi Masala",
          "Phulka Roti",
          "Steam Rice",
          "Fruit Custard"
        ],
        icon: Icons.dinner_dining_outlined,
        calories: "580 kcal",
      ),
    ),
    DayMenu(
      dayName: "Wednesday",
      shortDay: "Wed",
      dateStr: "Oct 25",
      isToday: true,
      breakfast: MealSlot(
        name: "Breakfast",
        timing: "08:00 AM - 09:30 AM",
        items: ["Aloo Paratha", "Fresh Curd", "Pickle", "Special Masala Tea"],
        icon: Icons.free_breakfast_outlined,
        calories: "490 kcal",
      ),
      lunch: MealSlot(
        name: "Lunch",
        timing: "12:30 PM - 02:00 PM",
        items: [
          "Chole Bhature",
          "Jeera Rice",
          "Onion Salad",
          "Mint Chutney",
          "Sweet Lassi"
        ],
        icon: Icons.lunch_dining_outlined,
        isSpecial: true,
        calories: "780 kcal",
      ),
      snacks: MealSlot(
        name: "Snacks",
        timing: "05:00 PM - 06:00 PM",
        items: ["Samosa (2 pcs)", "Green Chutney", "Tea / Coffee"],
        icon: Icons.local_cafe_outlined,
        calories: "320 kcal",
      ),
      dinner: MealSlot(
        name: "Dinner",
        timing: "08:00 PM - 09:30 PM",
        items: [
          "Mix Veg Curry",
          "Dal Makhani",
          "Butter Naan / Roti",
          "Pulav",
          "Gulab Jamun"
        ],
        icon: Icons.dinner_dining_outlined,
        isSpecial: true,
        calories: "750 kcal",
      ),
    ),
    DayMenu(
      dayName: "Thursday",
      shortDay: "Thu",
      dateStr: "Oct 26",
      breakfast: MealSlot(
        name: "Breakfast",
        timing: "08:00 AM - 09:30 AM",
        items: ["Upma with Sev", "Coconut Chutney", "Banana", "Tea"],
        icon: Icons.free_breakfast_outlined,
        calories: "340 kcal",
      ),
      lunch: MealSlot(
        name: "Lunch",
        timing: "12:30 PM - 02:00 PM",
        items: ["Soyabean Curry", "Dal Tadka", "Rice", "Chapati", "Buttermilk"],
        icon: Icons.lunch_dining_outlined,
        calories: "590 kcal",
      ),
      snacks: MealSlot(
        name: "Snacks",
        timing: "05:00 PM - 06:00 PM",
        items: ["Bhel Puri", "Lemon Juice"],
        icon: Icons.local_cafe_outlined,
        calories: "210 kcal",
      ),
      dinner: MealSlot(
        name: "Dinner",
        timing: "08:00 PM - 09:30 PM",
        items: [
          "Egg Curry / Shahi Paneer",
          "Dal Fry",
          "Chapati",
          "Rice",
          "Halwa"
        ],
        icon: Icons.dinner_dining_outlined,
        isSpecial: true,
        calories: "680 kcal",
      ),
    ),
    DayMenu(
      dayName: "Friday",
      shortDay: "Fri",
      dateStr: "Oct 27",
      breakfast: MealSlot(
        name: "Breakfast",
        timing: "08:00 AM - 09:30 AM",
        items: ["Uttapam", "Sambhar", "Tomato Chutney", "Coffee"],
        icon: Icons.free_breakfast_outlined,
        calories: "360 kcal",
      ),
      lunch: MealSlot(
        name: "Lunch",
        timing: "12:30 PM - 02:00 PM",
        items: ["Veg Biryani", "Mirchi Ka Salan", "Raita", "Papad"],
        icon: Icons.lunch_dining_outlined,
        calories: "640 kcal",
      ),
      snacks: MealSlot(
        name: "Snacks",
        timing: "05:00 PM - 06:00 PM",
        items: ["Bread Pakoda", "Sweet Chutney", "Chai"],
        icon: Icons.local_cafe_outlined,
        calories: "310 kcal",
      ),
      dinner: MealSlot(
        name: "Dinner",
        timing: "08:00 PM - 09:30 PM",
        items: [
          "Malai Kofta",
          "Yellow Dal",
          "Butter Roti",
          "Jeera Rice",
          "Rasgulla"
        ],
        icon: Icons.dinner_dining_outlined,
        isSpecial: true,
        calories: "710 kcal",
      ),
    ),
    DayMenu(
      dayName: "Saturday",
      shortDay: "Sat",
      dateStr: "Oct 28",
      breakfast: MealSlot(
        name: "Breakfast",
        timing: "08:00 AM - 09:30 AM",
        items: ["Methi Paratha", "Curd", "Boiled Eggs / Fruit", "Tea"],
        icon: Icons.free_breakfast_outlined,
        calories: "410 kcal",
      ),
      lunch: MealSlot(
        name: "Lunch",
        timing: "12:30 PM - 02:00 PM",
        items: ["Baingan Bharta", "Moong Dal", "Rice", "Chapati", "Salad"],
        icon: Icons.lunch_dining_outlined,
        calories: "540 kcal",
      ),
      snacks: MealSlot(
        name: "Snacks",
        timing: "05:00 PM - 06:00 PM",
        items: ["Pav Bhaji", "Lemon Tea"],
        icon: Icons.local_cafe_outlined,
        calories: "390 kcal",
      ),
      dinner: MealSlot(
        name: "Dinner",
        timing: "08:00 PM - 09:30 PM",
        items: ["Dal Makhani", "Jeera Aloo", "Naan", "Fried Rice", "Ice Cream"],
        icon: Icons.dinner_dining_outlined,
        isSpecial: true,
        calories: "740 kcal",
      ),
    ),
    DayMenu(
      dayName: "Sunday",
      shortDay: "Sun",
      dateStr: "Oct 29",
      breakfast: MealSlot(
        name: "Breakfast",
        timing: "08:30 AM - 10:00 AM",
        items: ["Chole Kulche", "Pickle", "Lassi / Coffee"],
        icon: Icons.free_breakfast_outlined,
        isSpecial: true,
        calories: "520 kcal",
      ),
      lunch: MealSlot(
        name: "Lunch",
        timing: "01:00 PM - 02:30 PM",
        items: [
          "Chicken Curry / Kadhai Paneer",
          "Dal Tadka",
          "Jeera Rice",
          "Roti",
          "Seviyan Kheer"
        ],
        icon: Icons.lunch_dining_outlined,
        isSpecial: true,
        calories: "820 kcal",
      ),
      snacks: MealSlot(
        name: "Snacks",
        timing: "05:00 PM - 06:00 PM",
        items: ["Biscuits & Cookies", "Special Masala Tea"],
        icon: Icons.local_cafe_outlined,
        calories: "190 kcal",
      ),
      dinner: MealSlot(
        name: "Dinner",
        timing: "08:00 PM - 09:30 PM",
        items: ["Light Khichdi", "Kadhi", "Aloo Fry", "Papad", "Curd"],
        icon: Icons.dinner_dining_outlined,
        calories: "480 kcal",
      ),
    ),
  ];
}
