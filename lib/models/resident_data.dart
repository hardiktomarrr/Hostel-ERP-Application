class ResidentProfile {
  final String name;
  final String roomNumber;
  final String block;
  final String avatarUrl;

  const ResidentProfile({
    required this.name,
    required this.roomNumber,
    required this.block,
    required this.avatarUrl,
  });
}

class DueInfo {
  final double amount;
  final String dueDate;
  final String month;
  final bool isOverdue;

  const DueInfo({
    required this.amount,
    required this.dueDate,
    required this.month,
    this.isOverdue = false,
  });
}

class MealItem {
  final String mealName;
  final String timing;
  final String menuDetails;
  final bool isServingNow;
  final String icon;

  const MealItem({
    required this.mealName,
    required this.timing,
    required this.menuDetails,
    this.isServingNow = false,
    required this.icon,
  });
}

class ShuttleInfo {
  final String departureTime;
  final String destination;
  final int availableSeats;
  final String status;

  const ShuttleInfo({
    required this.departureTime,
    required this.destination,
    required this.availableSeats,
    required this.status,
  });
}

class Announcement {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final bool isImportant;

  const Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isImportant = false,
  });
}
