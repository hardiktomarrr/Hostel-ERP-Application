import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleSelector({
    Key? key,
    required this.selectedRole,
    required this.onRoleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "LOGIN AS",
          style: AppTypography.labelSm(color: AppColors.slateGray),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEEF0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: _RoleTab(
                  role: UserRole.resident,
                  icon: Icons.person_outline_rounded,
                  isSelected: selectedRole == UserRole.resident,
                  onTap: () => onRoleChanged(UserRole.resident),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _RoleTab(
                  role: UserRole.owner,
                  icon: Icons.admin_panel_settings_outlined,
                  isSelected: selectedRole == UserRole.owner,
                  onTap: () => onRoleChanged(UserRole.owner),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleTab extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    Key? key,
    required this.role,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.slateGray,
                ),
                const SizedBox(width: 6),
                Text(
                  role.label,
                  style: AppTypography.bodyMd(
                    color: isSelected ? Colors.white : AppColors.deepNavy,
                  ).copyWith(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
