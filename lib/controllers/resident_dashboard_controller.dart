import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/resident_data.dart';

class ResidentDashboardController extends ChangeNotifier {
  int _currentNavIndex = 0;
  bool _isLoading = false;

  int get currentNavIndex => _currentNavIndex;
  bool get isLoading => _isLoading;

  ResidentProfile _profile = const ResidentProfile(
    name: "Rahul Sharma",
    roomNumber: "304",
    block: "Block B",
    avatarUrl: "https://i.pravatar.cc/150?img=11",
  );

  DueInfo _dues = const DueInfo(
    amount: 4500.0,
    dueDate: "5th Nov, 2023",
    month: "November 2023",
    isOverdue: false,
  );

  ResidentProfile get profile => _profile;
  DueInfo get dues => _dues;

  final List<Announcement> _announcements = [];
  List<Announcement> get announcements => _announcements;

  final List<MealItem> _todayMeals = [];
  List<MealItem> get todayMeals =>
      _todayMeals.isEmpty ? _defaultTodayMeals : _todayMeals;

  static const List<MealItem> _defaultTodayMeals = [
    MealItem(
      mealName: "Breakfast",
      timing: "08:00 - 09:30 AM",
      menuDetails: "Bread, Butter, Jam, Tea",
      isServingNow: true,
      icon: "breakfast",
    ),
    MealItem(
      mealName: "Lunch",
      timing: "12:30 - 02:00 PM",
      menuDetails: "Rice, Dal, Mixed Veg, Curd",
      isServingNow: false,
      icon: "lunch",
    ),
    MealItem(
      mealName: "Snacks",
      timing: "05:00 - 06:00 PM",
      menuDetails: "Samosa, Tea",
      isServingNow: false,
      icon: "snacks",
    ),
    MealItem(
      mealName: "Dinner",
      timing: "08:00 - 09:30 PM",
      menuDetails: "Paneer, Roti, Dal, Rice",
      isServingNow: false,
      icon: "dinner",
    ),
  ];

  ShuttleInfo _nextShuttle = const ShuttleInfo(
    departureTime: "09:15 AM",
    destination: "College (Main Campus)",
    availableSeats: 8,
    status: "Hostel to College",
  );

  ShuttleInfo get nextShuttle => _nextShuttle;

  StreamSubscription? _announcementsSub;
  StreamSubscription? _residentSub;
  StreamSubscription? _menuSub;
  StreamSubscription? _shuttleSub;
  Timer? _shuttleTimer;

  ResidentDashboardController() {
    _initAnnouncementsStream();
    _initResidentStream();
    _initMenuStream();
    _initShuttleStream();
    _shuttleTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateUpcomingShuttle();
    });
  }

  void _initAnnouncementsStream() {
    _announcementsSub = FirebaseFirestore.instance
        .collection('announcements')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        _seedDefaultAnnouncements();
        return;
      }
      final List<Announcement> loaded = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        loaded.add(Announcement(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          timeAgo: data['timeAgo'] ?? 'Just now',
          isImportant: data['isImportant'] ?? false,
        ));
      }
      loaded.sort((a, b) => b.id.compareTo(a.id));
      _announcements.clear();
      _announcements.addAll(loaded);
      notifyListeners();
    });
  }

  Future<void> _seedDefaultAnnouncements() async {
    final batch = FirebaseFirestore.instance.batch();
    final List<Map<String, dynamic>> defaultAnnouncements = [
      {
        'id': 'ANN-1002',
        'title': 'Diwali Celebration Schedule',
        'description':
            'Join us for the annual Diwali celebration in the common area at 7 PM. Special festive dinner will be served.',
        'timeAgo': '2 hours ago',
        'isImportant': true,
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'id': 'ANN-1001',
        'title': 'Water Supply Maintenance',
        'description':
            'Water supply will be interrupted in Block B tomorrow between 10 AM and 2 PM due to urgent pipe maintenance.',
        'timeAgo': '1 day ago',
        'isImportant': false,
        'timestamp': FieldValue.serverTimestamp(),
      },
    ];

    for (var ann in defaultAnnouncements) {
      final docRef =
          FirebaseFirestore.instance.collection('announcements').doc(ann['id']);
      batch.set(docRef, ann);
    }
    await batch.commit();
  }

  void _initResidentStream() {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? 'user1@lakshya.com';
    _residentSub = FirebaseFirestore.instance
        .collection('residents')
        .doc(email)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        _seedDefaultResident(email);
        return;
      }
      final data = snapshot.data();
      if (data != null) {
        _profile = ResidentProfile(
          name: data['name'] ?? 'Resident',
          roomNumber: data['roomNumber'] ?? 'N/A',
          block: data['block'] ?? 'N/A',
          avatarUrl: data['avatarUrl'] ?? 'https://i.pravatar.cc/150?img=11',
        );
        _dues = DueInfo(
          amount: (data['dueAmount'] ?? 0.0).toDouble(),
          dueDate: data['dueDate'] ?? '',
          month: data['dueMonth'] ?? '',
          isOverdue: data['isOverdue'] ?? false,
        );
        notifyListeners();
      }
    });
  }

  Future<void> _seedDefaultResident(String email) async {
    Map<String, dynamic> data;
    if (email == 'user2@lakshya.com') {
      data = {
        'name': 'Priya Patel',
        'roomNumber': '102',
        'block': 'Block A',
        'avatarUrl': 'https://i.pravatar.cc/150?img=47',
        'dueAmount': 0.0,
        'dueDate': 'No Dues Pending',
        'dueMonth': 'N/A',
        'isOverdue': false,
      };
    } else {
      data = {
        'name': 'Rahul Sharma',
        'roomNumber': '304',
        'block': 'Block B',
        'avatarUrl': 'https://i.pravatar.cc/150?img=11',
        'dueAmount': 4500.0,
        'dueDate': '5th Nov, 2023',
        'dueMonth': 'November 2023',
        'isOverdue': false,
      };
    }
    await FirebaseFirestore.instance
        .collection('residents')
        .doc(email)
        .set(data);
  }

  void setNavIndex(int index) {
    if (_currentNavIndex != index) {
      _currentNavIndex = index;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));
    _isLoading = false;
    notifyListeners();
  }

  void _initMenuStream() {
    const weekdaysMap = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    final currentDayName = weekdaysMap[DateTime.now().weekday] ?? 'Wednesday';

    _menuSub = FirebaseFirestore.instance
        .collection('mess_menu')
        .doc(currentDayName)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          _todayMeals.clear();

          final breakfastItems =
              _menuItemsToText(data['breakfast'] ?? "Bread, Butter, Jam, Tea");
          final lunchItems =
              _menuItemsToText(data['lunch'] ?? "Rice, Dal, Mixed Veg, Curd");
          final snacksItems = _menuItemsToText(data['snacks'] ?? "Samosa, Tea");
          final dinnerItems =
              _menuItemsToText(data['dinner'] ?? "Paneer, Roti, Dal, Rice");

          _todayMeals.add(MealItem(
            mealName: "Breakfast",
            timing: "08:00 - 09:30 AM",
            menuDetails: breakfastItems,
            isServingNow: _isServingNow(8, 0, 9, 30),
            icon: "breakfast",
          ));
          _todayMeals.add(MealItem(
            mealName: "Lunch",
            timing: "12:30 - 02:00 PM",
            menuDetails: lunchItems,
            isServingNow: _isServingNow(12, 30, 14, 0),
            icon: "lunch",
          ));
          _todayMeals.add(MealItem(
            mealName: "Snacks",
            timing: "05:00 - 06:00 PM",
            menuDetails: snacksItems,
            isServingNow: _isServingNow(17, 0, 18, 0),
            icon: "snacks",
          ));
          _todayMeals.add(MealItem(
            mealName: "Dinner",
            timing: "08:00 - 09:30 PM",
            menuDetails: dinnerItems,
            isServingNow: _isServingNow(20, 0, 21, 30),
            icon: "dinner",
          ));

          notifyListeners();
        }
      } else {
        _todayMeals.clear();
        notifyListeners();
      }
    });
  }

  String _menuItemsToText(Object value) {
    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .join(', ');
    }
    return value.toString();
  }

  bool _isServingNow(int startHour, int startMin, int endHour, int endMin) {
    final now = DateTime.now();
    final startTime =
        DateTime(now.year, now.month, now.day, startHour, startMin);
    final endTime = DateTime(now.year, now.month, now.day, endHour, endMin);
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  List<Map<String, dynamic>> _currentDayTrips = [];

  static const Map<String, List<Map<String, String>>> _defaultCabSchedules = {
    'Monday': [
      {'time': '08:30 AM', 'destination': 'Campus Main Gate', 'seats': '15', 'status': 'Scheduled'},
      {'time': '12:30 PM', 'destination': 'Metro Station', 'seats': '12', 'status': 'Scheduled'},
      {'time': '05:30 PM', 'destination': 'Campus Main Gate', 'seats': '18', 'status': 'Scheduled'},
      {'time': '08:30 PM', 'destination': 'Metro Station', 'seats': '10', 'status': 'Scheduled'},
    ],
    'Tuesday': [
      {'time': '08:30 AM', 'destination': 'Campus Main Gate', 'seats': '15', 'status': 'Scheduled'},
      {'time': '01:00 PM', 'destination': 'Metro Station', 'seats': '10', 'status': 'Scheduled'},
      {'time': '05:30 PM', 'destination': 'Campus Main Gate', 'seats': '18', 'status': 'Scheduled'},
      {'time': '08:00 PM', 'destination': 'Shopping Mall', 'seats': '12', 'status': 'Scheduled'},
    ],
    'Wednesday': [
      {'time': '08:30 AM', 'destination': 'Campus Main Gate', 'seats': '15', 'status': 'Scheduled'},
      {'time': '12:30 PM', 'destination': 'Metro Station', 'seats': '12', 'status': 'Scheduled'},
      {'time': '05:30 PM', 'destination': 'Campus Main Gate', 'seats': '18', 'status': 'Scheduled'},
      {'time': '08:30 PM', 'destination': 'Metro Station', 'seats': '10', 'status': 'Scheduled'},
    ],
    'Thursday': [
      {'time': '08:30 AM', 'destination': 'Campus Main Gate', 'seats': '15', 'status': 'Scheduled'},
      {'time': '01:00 PM', 'destination': 'Metro Station', 'seats': '10', 'status': 'Scheduled'},
      {'time': '05:30 PM', 'destination': 'Campus Main Gate', 'seats': '18', 'status': 'Scheduled'},
    ],
    'Friday': [
      {'time': '08:30 AM', 'destination': 'Campus Main Gate', 'seats': '15', 'status': 'Scheduled'},
      {'time': '12:30 PM', 'destination': 'Metro Station', 'seats': '12', 'status': 'Scheduled'},
      {'time': '05:30 PM', 'destination': 'Campus Main Gate', 'seats': '18', 'status': 'Scheduled'},
      {'time': '08:30 PM', 'destination': 'Metro Station', 'seats': '10', 'status': 'Scheduled'},
      {'time': '10:00 PM', 'destination': 'City Center', 'seats': '14', 'status': 'Scheduled'},
    ],
    'Saturday': [
      {'time': '09:00 AM', 'destination': 'Shopping Mall', 'seats': '20', 'status': 'Scheduled'},
      {'time': '02:00 PM', 'destination': 'City Center', 'seats': '20', 'status': 'Scheduled'},
      {'time': '07:00 PM', 'destination': 'Metro Station', 'seats': '15', 'status': 'Scheduled'},
    ],
    'Sunday': [
      {'time': '09:00 AM', 'destination': 'City Center', 'seats': '20', 'status': 'Scheduled'},
      {'time': '03:00 PM', 'destination': 'Shopping Mall', 'seats': '20', 'status': 'Scheduled'},
      {'time': '08:00 PM', 'destination': 'Metro Station', 'seats': '15', 'status': 'Scheduled'},
    ],
  };

  void _initShuttleStream() {
    const weekdaysMap = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    final currentDayName = weekdaysMap[DateTime.now().weekday] ?? 'Wednesday';

    _shuttleSub = FirebaseFirestore.instance
        .collection('cab_schedules')
        .doc(currentDayName)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          final rawTrips = data['trips'] as List<dynamic>? ?? [];
          final List<Map<String, dynamic>> parsedTrips = [];
          for (var t in rawTrips) {
            if (t is Map) {
              parsedTrips.add(Map<String, dynamic>.from(t));
            }
          }
          _currentDayTrips = parsedTrips;
        } else {
          _currentDayTrips = List<Map<String, dynamic>>.from(_defaultCabSchedules[currentDayName] ?? []);
        }
      } else {
        _currentDayTrips = List<Map<String, dynamic>>.from(_defaultCabSchedules[currentDayName] ?? []);
      }
      _updateUpcomingShuttle();
    });
  }

  void _updateUpcomingShuttle() {
    if (_currentDayTrips.isEmpty) {
      final updatedShuttle = const ShuttleInfo(
        departureTime: "No upcoming cab",
        destination: "N/A",
        availableSeats: 0,
        status: "N/A",
      );
      if (_nextShuttle.departureTime != updatedShuttle.departureTime ||
          _nextShuttle.destination != updatedShuttle.destination ||
          _nextShuttle.availableSeats != updatedShuttle.availableSeats ||
          _nextShuttle.status != updatedShuttle.status) {
        _nextShuttle = updatedShuttle;
        notifyListeners();
      }
      return;
    }

    final now = DateTime.now();
    Map<String, dynamic>? nextTrip;

    for (var trip in _currentDayTrips) {
      final timeStr = trip['time'] as String? ?? '';
      final timeOfDay = _parseTimeOfDay(timeStr);
      if (timeOfDay != null) {
        final tripDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );
        if (tripDateTime.isAfter(now)) {
          if (nextTrip == null) {
            nextTrip = trip;
          } else {
            final prevTime = _parseTimeOfDay(nextTrip['time'] as String? ?? '');
            if (prevTime != null) {
              final prevDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                prevTime.hour,
                prevTime.minute,
              );
              if (tripDateTime.isBefore(prevDateTime)) {
                nextTrip = trip;
              }
            }
          }
        }
      }
    }

    final ShuttleInfo updatedShuttle;
    if (nextTrip != null) {
      updatedShuttle = ShuttleInfo(
        departureTime: nextTrip['time'] ?? 'N/A',
        destination: nextTrip['destination'] ?? 'N/A',
        availableSeats: int.tryParse((nextTrip['seats'] ?? '8').toString()) ?? 8,
        status: nextTrip['status'] ?? 'Scheduled',
      );
    } else {
      updatedShuttle = const ShuttleInfo(
        departureTime: "No upcoming cab",
        destination: "N/A",
        availableSeats: 0,
        status: "N/A",
      );
    }

    if (_nextShuttle.departureTime != updatedShuttle.departureTime ||
        _nextShuttle.destination != updatedShuttle.destination ||
        _nextShuttle.availableSeats != updatedShuttle.availableSeats ||
        _nextShuttle.status != updatedShuttle.status) {
      _nextShuttle = updatedShuttle;
      notifyListeners();
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      if (parts.length != 2) return null;
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final amPm = parts[1].toUpperCase();

      if (amPm == 'PM' && hour < 12) {
        hour += 12;
      } else if (amPm == 'AM' && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _announcementsSub?.cancel();
    _residentSub?.cancel();
    _menuSub?.cancel();
    _shuttleSub?.cancel();
    _shuttleTimer?.cancel();
    super.dispose();
  }
}
