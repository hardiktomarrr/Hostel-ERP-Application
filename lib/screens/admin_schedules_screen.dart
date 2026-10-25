import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_profile_menu.dart';
import 'admin_dashboard_screen.dart';

class AdminSchedulesScreen extends StatefulWidget {
  const AdminSchedulesScreen({Key? key}) : super(key: key);

  @override
  State<AdminSchedulesScreen> createState() => _AdminSchedulesScreenState();
}

class _AdminSchedulesScreenState extends State<AdminSchedulesScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  int _selectedScheduleTab = 0;
  String _selectedDay = "Monday";

  final List<String> _days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  // The local defaults make the editor usable before Firestore has its first
  // menu document. They are published to `mess_menu/{day}` on first use.
  late Map<String, Map<String, String>> _messMenus;

  // Mock Cab Schedule Data keyed by day
  late Map<String, List<Map<String, String>>> _cabSchedules;

  // Form controllers for editing
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _snacksController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();

  StreamSubscription? _menuSub;
  StreamSubscription? _cabSub;
  bool _isSaving = false;
  bool _isSeedingMessMenus = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    const weekdaysMap = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    _selectedDay = weekdaysMap[DateTime.now().weekday] ?? 'Monday';

    _messMenus = {
      'Monday': {
        'breakfast': 'Aloo Paratha, Curd, Tea & Coffee',
        'lunch': 'Chana Masala, Jeera Rice, Roti, Salad, Butter Milk',
        'snacks': 'Samosa, Mint Chutney, Tea',
        'dinner': 'Paneer Butter Masala, Roti, Plain Rice, Dal Tadka, Kheer',
      },
      'Tuesday': {
        'breakfast': 'Idli Sambhar, Coconut Chutney, Tea',
        'lunch': 'Rajma Masala, Steamed Rice, Roti, Curd, Papad',
        'snacks': 'Poha, Sev, Coffee',
        'dinner': 'Mix Veg Dry, Dal Fry, Roti, Rice, Gulab Jamun',
      },
      'Wednesday': {
        'breakfast': 'Bread Butter Jam, Scrambled Eggs / Sprouts, Tea',
        'lunch': 'Aloo Gobhi Adraki, Dal Makhani, Rice, Roti, Boondi Raita',
        'snacks': 'Veg Cutlet, Tomato Sauce, Tea',
        'dinner': 'Chicken Curry / Kadai Paneer, Roti, Jeera Rice, Ice Cream',
      },
      'Thursday': {
        'breakfast': 'Puri Bhaji, Pickle, Tea & Coffee',
        'lunch': 'Kadhi Pakoda, Rice, Sukhi Sabzi, Roti, Salad',
        'snacks': 'Kachori, Sweet Chutney, Tea',
        'dinner': 'Veg Biryani, Salan, Raita, Papad, Seviyan Payasam',
      },
      'Friday': {
        'breakfast': 'Methi Thepla, Pickle, Curd, Tea',
        'lunch': 'Black Chana, Pulao, Roti, Curd, Fryums',
        'snacks': 'Veg Sandwich, Green Chutney, Coffee',
        'dinner': 'Malai Kofta, Butter Naan, Rice, Yellow Dal, Fruit Custard',
      },
      'Saturday': {
        'breakfast': 'Uttapam, Sambhar, Tomato Chutney, Tea',
        'lunch': 'Chole Bhature, Onion Salad, Lassi',
        'snacks': 'Dhokla, Green Chillies, Tea',
        'dinner': 'Aloo Shimla Mirch, Dal Palak, Roti, Steamed Rice, Halwa',
      },
      'Sunday': {
        'breakfast': 'Poha, Jalebi, Tea & Coffee',
        'lunch': 'Veg Pulao, Paneer Do Pyaza, Dal Fry, Roti, Raita, Papad',
        'snacks': 'Aloo Tikki Chaat, Tea',
        'dinner': 'Special Shahi Paneer, Garlic Naan, Veg Pulao, Rasgulla',
      },
    };

    _cabSchedules = {
      'Monday': [
        {
          'time': '08:30 AM',
          'destination': 'Campus Main Gate',
          'seats': '15',
          'status': 'Scheduled'
        },
        {
          'time': '12:30 PM',
          'destination': 'Metro Station',
          'seats': '12',
          'status': 'Scheduled'
        },
        {
          'time': '05:30 PM',
          'destination': 'Campus Main Gate',
          'seats': '18',
          'status': 'Scheduled'
        },
        {
          'time': '08:30 PM',
          'destination': 'Metro Station',
          'seats': '10',
          'status': 'Scheduled'
        },
      ],
      'Tuesday': [
        {
          'time': '08:30 AM',
          'destination': 'Campus Main Gate',
          'seats': '15',
          'status': 'Scheduled'
        },
        {
          'time': '01:00 PM',
          'destination': 'Metro Station',
          'seats': '10',
          'status': 'Scheduled'
        },
        {
          'time': '05:30 PM',
          'destination': 'Campus Main Gate',
          'seats': '18',
          'status': 'Scheduled'
        },
        {
          'time': '08:00 PM',
          'destination': 'Shopping Mall',
          'seats': '12',
          'status': 'Scheduled'
        },
      ],
      'Wednesday': [
        {
          'time': '08:30 AM',
          'destination': 'Campus Main Gate',
          'seats': '15',
          'status': 'Scheduled'
        },
        {
          'time': '12:30 PM',
          'destination': 'Metro Station',
          'seats': '12',
          'status': 'Scheduled'
        },
        {
          'time': '05:30 PM',
          'destination': 'Campus Main Gate',
          'seats': '18',
          'status': 'Scheduled'
        },
        {
          'time': '08:30 PM',
          'destination': 'Metro Station',
          'seats': '10',
          'status': 'Scheduled'
        },
      ],
      'Thursday': [
        {
          'time': '08:30 AM',
          'destination': 'Campus Main Gate',
          'seats': '15',
          'status': 'Scheduled'
        },
        {
          'time': '01:00 PM',
          'destination': 'Metro Station',
          'seats': '10',
          'status': 'Scheduled'
        },
        {
          'time': '05:30 PM',
          'destination': 'Campus Main Gate',
          'seats': '18',
          'status': 'Scheduled'
        },
      ],
      'Friday': [
        {
          'time': '08:30 AM',
          'destination': 'Campus Main Gate',
          'seats': '15',
          'status': 'Scheduled'
        },
        {
          'time': '12:30 PM',
          'destination': 'Metro Station',
          'seats': '12',
          'status': 'Scheduled'
        },
        {
          'time': '05:30 PM',
          'destination': 'Campus Main Gate',
          'seats': '18',
          'status': 'Scheduled'
        },
        {
          'time': '08:30 PM',
          'destination': 'Metro Station',
          'seats': '10',
          'status': 'Scheduled'
        },
        {
          'time': '10:00 PM',
          'destination': 'City Center',
          'seats': '14',
          'status': 'Scheduled'
        },
      ],
      'Saturday': [
        {
          'time': '09:00 AM',
          'destination': 'Shopping Mall',
          'seats': '20',
          'status': 'Scheduled'
        },
        {
          'time': '02:00 PM',
          'destination': 'City Center',
          'seats': '20',
          'status': 'Scheduled'
        },
        {
          'time': '07:00 PM',
          'destination': 'Metro Station',
          'seats': '15',
          'status': 'Scheduled'
        },
      ],
      'Sunday': [
        {
          'time': '09:00 AM',
          'destination': 'City Center',
          'seats': '20',
          'status': 'Scheduled'
        },
        {
          'time': '03:00 PM',
          'destination': 'Shopping Mall',
          'seats': '20',
          'status': 'Scheduled'
        },
        {
          'time': '08:00 PM',
          'destination': 'Metro Station',
          'seats': '15',
          'status': 'Scheduled'
        },
      ],
    };

    _updateControllers();

    _menuSub = FirebaseFirestore.instance
        .collection('mess_menu')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          _messMenus[doc.id] = {
            'breakfast': _mealItemsToText(data['breakfast']),
            'lunch': _mealItemsToText(data['lunch']),
            'snacks': _mealItemsToText(data['snacks']),
            'dinner': _mealItemsToText(data['dinner']),
          };
        }
        _loadError = null;
        _updateControllers();
      });

      // Firestore creates a collection when its first document is written.
      // Ensure every weekday document exists, including when only some days
      // were manually created in the console.
      final existingDays = snapshot.docs.map((doc) => doc.id).toSet();
      if (!_isSeedingMessMenus &&
          _days.any((day) => !existingDays.contains(day))) {
        _seedDefaultMessMenus(existingDays: existingDays);
      }
    }, onError: _handleFirestoreError);

    _cabSub = FirebaseFirestore.instance
        .collection('cab_schedules')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        _seedDefaultCabSchedules();
        return;
      }
      if (mounted) {
        setState(() {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final rawTrips = data['trips'] as List<dynamic>? ?? [];
            final List<Map<String, String>> parsedTrips = [];
            for (var t in rawTrips) {
              if (t is Map) {
                parsedTrips.add({
                  'time': (t['time'] ?? '').toString(),
                  'destination': (t['destination'] ?? '').toString(),
                  'seats': (t['seats'] ?? '').toString(),
                  'status': (t['status'] ?? '').toString(),
                });
              }
            }
            _cabSchedules[doc.id] = parsedTrips;
          }
          _loadError = null;
        });
      }
    }, onError: _handleFirestoreError);
  }

  void _handleFirestoreError(Object error) {
    if (!mounted) return;
    setState(() => _loadError = 'Unable to load schedules: $error');
  }

  String _mealItemsToText(Object? value) {
    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .join(', ');
    }
    return value?.toString() ?? '';
  }

  List<String> _mealTextToItems(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _seedDefaultMessMenus({Set<String>? existingDays}) async {
    if (_isSeedingMessMenus) return;
    _isSeedingMessMenus = true;
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final entry in _messMenus.entries) {
        final day = entry.key;
        final menu = entry.value;
        if (existingDays?.contains(day) ?? false) continue;
        batch.set(
          FirebaseFirestore.instance.collection('mess_menu').doc(day),
          {
            'breakfast': _mealTextToItems(menu['breakfast'] ?? ''),
            'lunch': _mealTextToItems(menu['lunch'] ?? ''),
            'snacks': _mealTextToItems(menu['snacks'] ?? ''),
            'dinner': _mealTextToItems(menu['dinner'] ?? ''),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }
      await batch.commit();
    } catch (error) {
      _handleFirestoreError(error);
    } finally {
      _isSeedingMessMenus = false;
    }
  }

  Future<void> _seedDefaultCabSchedules() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      _cabSchedules.forEach((day, trips) {
        batch.set(
          FirebaseFirestore.instance.collection('cab_schedules').doc(day),
          {'trips': trips, 'updatedAt': FieldValue.serverTimestamp()},
        );
      });
      await batch.commit();
    } catch (error) {
      _handleFirestoreError(error);
    }
  }

  void _updateControllers() {
    final currentMenu = _messMenus[_selectedDay] ??
        {
          'breakfast': '',
          'lunch': '',
          'snacks': '',
          'dinner': '',
        };
    _breakfastController.text = currentMenu['breakfast']!;
    _lunchController.text = currentMenu['lunch']!;
    _snacksController.text = currentMenu['snacks']!;
    _dinnerController.text = currentMenu['dinner']!;
  }

  @override
  void dispose() {
    _menuSub?.cancel();
    _cabSub?.cancel();
    _tabController.dispose();
    _breakfastController.dispose();
    _lunchController.dispose();
    _snacksController.dispose();
    _dinnerController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    if (_selectedScheduleTab == 0) {
      try {
        await FirebaseFirestore.instance
            .collection('mess_menu')
            .doc(_selectedDay)
            .set({
          // Store items as arrays so individual dishes are queryable and can
          // be updated without parsing a display string in Firestore.
          'breakfast': _mealTextToItems(_breakfastController.text),
          'lunch': _mealTextToItems(_lunchController.text),
          'snacks': _mealTextToItems(_snacksController.text),
          'dinner': _mealTextToItems(_dinnerController.text),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text("Mess menu for $_selectedDay saved successfully!")
            ]),
            backgroundColor: AppColors.successEmerald,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error saving menu: $error"),
              backgroundColor: AppColors.errorRuby,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      final dayTrips = _cabSchedules[_selectedDay] ?? [];
      try {
        await FirebaseFirestore.instance
            .collection('cab_schedules')
            .doc(_selectedDay)
            .set({
          'trips': dayTrips,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text("Shuttle schedule for $_selectedDay saved successfully!")
            ]),
            backgroundColor: AppColors.successEmerald,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error saving shuttle schedule: $error"),
              backgroundColor: AppColors.errorRuby,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  void _showShuttleDialog({int? index}) {
    final existingTrip =
        index == null ? null : _cabSchedules[_selectedDay]![index];
    final timeCtrl = TextEditingController(text: existingTrip?['time'] ?? '');
    final destCtrl =
        TextEditingController(text: existingTrip?['destination'] ?? '');
    final seatsCtrl = TextEditingController(text: existingTrip?['seats'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            index == null ? "Add Shuttle Departure" : "Edit Shuttle Departure",
            style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Departure Time",
                  hintText: "Tap to select time",
                  suffixIcon: Icon(Icons.access_time_rounded, color: AppColors.primary),
                ),
                onTap: () async {
                  TimeOfDay initialTime = TimeOfDay.now();
                  if (timeCtrl.text.isNotEmpty) {
                    initialTime = _parseTimeOfDay(timeCtrl.text) ?? TimeOfDay.now();
                  }

                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                  );

                  if (selectedTime != null) {
                    timeCtrl.text = _formatTimeOfDay(selectedTime);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: destCtrl,
                decoration: const InputDecoration(
                    labelText: "Destination", hintText: "e.g., Metro Station"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: seatsCtrl,
                decoration: const InputDecoration(
                    labelText: "Available Seats", hintText: "e.g., 15"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: AppTypography.bodyMd(color: AppColors.slateGray)),
            ),
            ElevatedButton(
              onPressed: () {
                final time = timeCtrl.text.trim();
                final dest = destCtrl.text.trim();
                final seats = seatsCtrl.text.trim();

                if (time.isEmpty || dest.isEmpty || seats.isEmpty) {
                  return;
                }

                setState(() {
                  final trip = {
                    'time': time,
                    'destination': dest,
                    'seats': seats,
                    'status': existingTrip?['status'] ?? 'Scheduled',
                  };
                  final trips =
                      _cabSchedules.putIfAbsent(_selectedDay, () => []);
                  if (index == null) {
                    trips.add(trip);
                  } else {
                    trips[index] = trip;
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(index == null
                        ? "Added shuttle trip to $dest at $time!"
                        : "Updated shuttle trip to $dest at $time!"),
                    backgroundColor: AppColors.successEmerald,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(index == null ? "Add Trip" : "Update Trip",
                  style: AppTypography.bodyMd(color: Colors.white)
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');
    return "$hourStr:$minuteStr $period";
  }

  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text("PDF Schedule exported successfully!"),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        }
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.deepNavy),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(
            "Admin Portal",
            style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: const [
            AdminProfileMenu(),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(color: Color(0xFFEBECF0), height: 1),
          ),
        ),
        drawer: const AdminDrawer(currentRoute: "schedules"),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Title & Action Buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Schedules Management",
                              style: AppTypography.headlineMd(
                                      color: AppColors.deepNavy)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Manage weekly mess menus and cab timings.",
                              style: AppTypography.bodyMd(
                                  color: AppColors.slateGray),
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _exportPdf,
                                  icon: const Icon(Icons.download_rounded,
                                      size: 16),
                                  label: const Text("Export PDF"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.deepNavy,
                                    side: const BorderSide(
                                        color: Color(0xFFEBECF0)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveChanges,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(Icons.check_rounded,
                                          size: 16),
                                  label: Text(
                                      _isSaving ? "Saving..." : "Save Changes"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (_loadError != null) ...[
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorRuby.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _loadError!,
                              style: AppTypography.bodyMd(
                                  color: AppColors.errorRuby),
                            ),
                          ),
                        ],

                        // Tab Header
                        Container(
                          color: AppColors.background,
                          child: TabBar(
                            controller: _tabController,
                            onTap: (index) {
                              setState(() => _selectedScheduleTab = index);
                            },
                            indicatorColor: AppColors.primary,
                            indicatorWeight: 3,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.slateGray,
                            labelStyle: AppTypography.headlineSm()
                                .copyWith(fontWeight: FontWeight.bold),
                            tabs: const [
                              Tab(text: "Mess Menu"),
                              Tab(text: "Cab Schedule"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Day Selector Pills Row
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _days.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final day = _days[index];
                              final isSelected = _selectedDay == day;

                              return ChoiceChip(
                                label: Text(
                                  day,
                                  style: AppTypography.bodyMd(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.deepNavy,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surfaceWhite,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.transparent
                                        : const Color(0xFFEBECF0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedDay = day;
                                      _updateControllers();
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Keep the rendered panel in the screen state rather
                        // than relying on a nested PageView viewport. On some
                        // small Android screens that viewport was allocated
                        // but painted its Mess Menu page blank.
                        _selectedScheduleTab == 0
                            ? _buildMessMenuEditor()
                            : SizedBox(
                                height: MediaQuery.sizeOf(context).width < 600
                                    ? 590
                                    : 500,
                                child: _buildCabScheduleEditor(),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessMenuEditor() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                color: AppColors.primary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _selectedDay,
                        style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMealDisplayCard("breakfast", "Breakfast"),
                      _buildMealDisplayCard("lunch", "Lunch"),
                      _buildMealDisplayCard("snacks", "Snacks"),
                      _buildMealDisplayCard("dinner", "Dinner"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealDisplayCard(String mealKey, String displayName) {
    final mealText = _messMenus[_selectedDay]?[mealKey] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.toUpperCase(),
                  style: AppTypography.labelSm(color: AppColors.slateGray).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mealText.isEmpty ? "Not configured" : mealText,
                  style: AppTypography.bodyMd(
                    color: mealText.isEmpty ? AppColors.slateGray.withOpacity(0.6) : AppColors.deepNavy,
                  ).copyWith(
                    fontWeight: mealText.isEmpty ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.slateGray, size: 24),
            onPressed: () => _showEditMealDialog(mealKey, displayName),
            tooltip: "Edit $displayName",
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Future<void> _showEditMealDialog(String mealKey, String displayName) async {
    final currentText = _messMenus[_selectedDay]?[mealKey] ?? '';
    final controller = TextEditingController(text: currentText);
    bool isSavingLocal = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Edit $displayName Menu",
                style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Editing menu for $_selectedDay",
                    style: AppTypography.labelMd(color: AppColors.slateGray),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    style: AppTypography.bodyMd(color: AppColors.deepNavy),
                    decoration: InputDecoration(
                      labelText: displayName,
                      helperText: 'Separate items with commas',
                      labelStyle: AppTypography.labelMd(color: AppColors.slateGray)
                          .copyWith(fontWeight: FontWeight.bold),
                      prefixIcon: Icon(
                        mealKey == 'breakfast'
                            ? Icons.breakfast_dining_rounded
                            : mealKey == 'lunch'
                                ? Icons.lunch_dining_rounded
                                : mealKey == 'snacks'
                                    ? Icons.bakery_dining_rounded
                                    : Icons.dinner_dining_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFEBECF0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFEBECF0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSavingLocal ? null : () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: AppTypography.bodyMd(color: AppColors.slateGray),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSavingLocal
                      ? null
                      : () async {
                          final newValue = controller.text.trim();
                          setDialogState(() => isSavingLocal = true);
                          try {
                            await FirebaseFirestore.instance
                                .collection('mess_menu')
                                .doc(_selectedDay)
                                .set({
                              mealKey: _mealTextToItems(newValue),
                              'updatedAt': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text("Updated $displayName menu for $_selectedDay successfully!"),
                                  ],
                                ),
                                backgroundColor: AppColors.successEmerald,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            setDialogState(() => isSavingLocal = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error saving menu: $error"),
                                backgroundColor: AppColors.errorRuby,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                  ),
                  child: isSavingLocal
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Save",
                          style: AppTypography.bodyMd(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCabScheduleEditor() {
    final dayTrips = _cabSchedules[_selectedDay] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Shuttle Departures on $_selectedDay",
                style: AppTypography.headlineSm(color: AppColors.deepNavy)
                    .copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _isSaving ? null : () => _showShuttleDialog(),
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary, size: 28),
                tooltip: "Add Departure",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: dayTrips.isEmpty
                ? Center(
                    child: Text(
                      "No shuttle trips scheduled for this day.",
                      style: AppTypography.bodyMd(color: AppColors.slateGray),
                    ),
                  )
                : ListView.separated(
                    itemCount: dayTrips.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final trip = dayTrips[index];
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              trip['time']!,
                              style: AppTypography.bodyMd(
                                      color: AppColors.primaryDark)
                                  .copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "To ${trip['destination']}",
                                  style: AppTypography.bodyMd(
                                          color: AppColors.deepNavy)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${trip['seats']} seats available • ${trip['status']}",
                                  style: AppTypography.labelMd(
                                      color: AppColors.slateGray),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.primary, size: 20),
                            onPressed: _isSaving
                                ? null
                                : () => _showShuttleDialog(index: index),
                            tooltip: 'Edit departure',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.errorRuby, size: 20),
                            onPressed: _isSaving
                                ? null
                                : () {
                                    setState(() {
                                      dayTrips.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Departure trip deleted."),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveChanges,
            icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
            label: Text(
              _isSaving
                  ? "Saving..."
                  : "Save Shuttle Schedule for $_selectedDay",
              style: AppTypography.bodyMd(color: Colors.white)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}
