import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_pending_payments_screen.dart';
import '../screens/admin_resident_management_screen.dart';
import '../screens/admin_schedules_screen.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/student_onboarding_screen.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // Close drawer first
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'manager@lakshya.com';
    final isSuperAdmin = email == 'admin@lakshya.com';
    final adminName = isSuperAdmin ? 'Admin User' : 'Manager User';
    final adminRole = isSuperAdmin ? 'Administrator' : 'Hostel Manager';

    return Drawer(
      backgroundColor: AppColors.surfaceWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEBECF0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lakshya's",
                          style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Structure ERP Admin",
                          style: AppTypography.labelMd(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    title: "Dashboard",
                    route: "dashboard",
                    targetScreen: const AdminDashboardScreen(),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.payment_outlined,
                    activeIcon: Icons.payments_rounded,
                    title: "Pending Payments",
                    route: "payments",
                    targetScreen: const AdminPendingPaymentsScreen(),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.people_outline_rounded,
                    activeIcon: Icons.people_alt_rounded,
                    title: "Resident Management",
                    route: "residents",
                    targetScreen: const AdminResidentManagementScreen(),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month_rounded,
                    title: "Schedules Management",
                    route: "schedules",
                    targetScreen: const AdminSchedulesScreen(),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_add_alt_1_outlined,
                    activeIcon: Icons.person_add_alt_1_rounded,
                    title: "Student Onboarding",
                    route: "onboard_student",
                    targetScreen: const StudentOnboardingScreen(),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.preview_outlined,
                    activeIcon: Icons.preview_rounded,
                    title: "Onboarding Preview",
                    route: "preview_onboarding",
                    targetScreen: const OnboardingScreen(isPreview: true),
                  ),
                ],
              ),
            ),
          ),

          // Drawer Footer with admin details & logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: Color(0xFFEBECF0), width: 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryContainer.withOpacity(0.5),
                  child: Text(
                    adminName.split(' ').map((e) => e[0]).join(''),
                    style: AppTypography.labelSm(color: AppColors.primaryDark).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        adminName,
                        style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        adminRole,
                        style: AppTypography.labelMd(color: AppColors.slateGray),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.errorRuby, size: 20),
                  onPressed: () async {
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
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
    required Widget targetScreen,
  }) {
    final isActive = currentRoute == route;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive ? () => Navigator.of(context).pop() : () => _navigateTo(context, targetScreen),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.slateGray,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: AppTypography.bodyMd(
                  color: isActive ? AppColors.primary : AppColors.deepNavy,
                ).copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
