import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/resident_dashboard_controller.dart';
import '../models/resident_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/announcements_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/next_cab_card.dart';
import '../widgets/resident_dues_card.dart';
import '../widgets/today_meals_card.dart';
import '../widgets/tickets_tab.dart';
import 'login_screen.dart';
import 'mess_menu_screen.dart';
import 'payments_screen.dart';


class ResidentDashboardScreen extends StatefulWidget {
  const ResidentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ResidentDashboardScreen> createState() => _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState extends State<ResidentDashboardScreen> {
  late final ResidentDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ResidentDashboardController();
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (_controller.currentNavIndex == 0 || _controller.currentNavIndex == 1) {
      return AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _buildProfileMenu(context),
        title: Text(
          "Lakshya's",
          style: AppTypography.headlineMd(color: AppColors.primary).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFEBECF0), height: 1),
        ),
      );
    }

    if (_controller.currentNavIndex == 2) {
      return AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: _buildProfileMenu(context),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Support & Maintenance",
              style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Raise and track maintenance requests",
              style: AppTypography.labelMd(color: AppColors.slateGray),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFEBECF0), height: 1),
        ),
      );
    }

    return AppBar();
  }

  Widget _buildProfileMenu(BuildContext context) {
    final profile = _controller.profile;
    return PopupMenuButton<String>(
      tooltip: "Profile options",
      offset: const Offset(12, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(profile.avatarUrl),
        ),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          try {
            await FirebaseAuth.instance.signOut();
          } catch (e) {
            debugPrint("Error signing out: $e");
          }
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        } else if (value == 'profile') {
          _showProfileDialog(context, profile);
        } else if (value == 'settings') {
          _showActionSnackBar("Settings option clicked!");
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(profile.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.name,
                        style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${profile.block} • Room ${profile.roomNumber}",
                        style: AppTypography.labelSm(color: AppColors.slateGray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_outline_rounded, color: AppColors.deepNavy, size: 20),
                const SizedBox(width: 12),
                Text(
                  "My Profile",
                  style: AppTypography.bodyMd(color: AppColors.deepNavy),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_outlined, color: AppColors.deepNavy, size: 20),
                const SizedBox(width: 12),
                Text(
                  "Settings",
                  style: AppTypography.bodyMd(color: AppColors.deepNavy),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.errorRuby, size: 20),
                const SizedBox(width: 12),
                Text(
                  "Logout",
                  style: AppTypography.bodyMd(color: AppColors.errorRuby).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  void _showProfileDialog(BuildContext context, ResidentProfile profile) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Resident Profile",
            style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(profile.avatarUrl),
              ),
              const SizedBox(height: 16),
              Text(
                profile.name,
                style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Block & Room: ${profile.block}, Room ${profile.roomNumber}",
                style: AppTypography.bodyMd(color: AppColors.slateGray),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Status", style: AppTypography.labelMd(color: AppColors.slateGray)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successEmerald.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Active",
                      style: AppTypography.labelSm(color: AppColors.successEmerald).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: AppTypography.bodyMd(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildHomeTab(BuildContext context, bool isDesktop) {
    return RefreshIndicator(
      onRefresh: _controller.refreshDashboard,
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pending Payment Notification Banner
                if (_controller.dues.amount > 0) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD), // Light warning yellow
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 4,
                              color: const Color(0xFFFF9F1C),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFB76E00)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Pending Payment Alert: ₹${_controller.dues.amount.toStringAsFixed(0)} due by ${_controller.dues.dueDate}.",
                                        style: AppTypography.bodyMd(color: const Color(0xFF856404)).copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _controller.setNavIndex(1); // Switch to Payments tab
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        backgroundColor: const Color(0xFFB76E00).withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: Text(
                                        "Pay Now",
                                        style: AppTypography.labelSm(color: const Color(0xFF856404)).copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
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
                ],

                if (isDesktop) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ResidentDuesCard(
                              dues: _controller.dues,
                              onPayDues: () => _controller.setNavIndex(1),
                            ),
                            const SizedBox(height: 24),
                            TodayMealsCard(
                              meals: _controller.todayMeals,
                              onViewFullMenu: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const MessMenuScreen()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NextCabCard(
                              shuttle: _controller.nextShuttle,
                              onBookSeat: () => _showActionSnackBar("Shuttle seat requested!"),
                            ),
                            const SizedBox(height: 24),
                            AnnouncementsCard(
                              announcements: _controller.announcements,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  ResidentDuesCard(
                    dues: _controller.dues,
                    onPayDues: () => _controller.setNavIndex(1),
                  ),
                  const SizedBox(height: 16),
                  TodayMealsCard(
                    meals: _controller.todayMeals,
                    onViewFullMenu: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MessMenuScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  NextCabCard(
                    shuttle: _controller.nextShuttle,
                    onBookSeat: () => _showActionSnackBar("Shuttle seat requested!"),
                  ),
                  const SizedBox(height: 16),
                  AnnouncementsCard(
                    announcements: _controller.announcements,
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          switch (_controller.currentNavIndex) {
            case 1:
              return const PaymentsScreen(isEmbedded: true);
            case 2:
              return const TicketsTab();
            case 0:
            default:
              return _buildHomeTab(context, isDesktop);
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _controller.currentNavIndex,
        onTap: (index) {
          _controller.setNavIndex(index);
        },
      ),
    );
  }

  void _showActionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
