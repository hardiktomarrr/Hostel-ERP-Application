import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../screens/login_screen.dart';

class AdminProfileMenu extends StatelessWidget {
  const AdminProfileMenu({Key? key}) : super(key: key);

  void _showProfileDialog(BuildContext context, String name, String email, String role) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Administrator Profile",
            style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryContainer.withOpacity(0.5),
                child: Text(
                  name.split(' ').map((e) => e[0]).join(''),
                  style: AppTypography.headlineMd(color: AppColors.primaryDark).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: AppTypography.bodyMd(color: AppColors.slateGray),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Role", style: AppTypography.labelMd(color: AppColors.slateGray)),
                  Text(
                    role,
                    style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'manager@lakshya.com';
    final isSuperAdmin = email == 'admin@lakshya.com';
    final name = isSuperAdmin ? 'Admin User' : 'Manager User';
    final role = isSuperAdmin ? 'Administrator' : 'Hostel Manager';
    final initials = name.split(' ').map((e) => e[0]).join('');

    return PopupMenuButton<String>(
      tooltip: "Profile options",
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: AppTypography.labelSm(color: Colors.white).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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
          _showProfileDialog(context, name, email, role);
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
                  backgroundColor: AppColors.primaryContainer.withOpacity(0.5),
                  child: Text(
                    initials,
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
                        name,
                        style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        role,
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
}
