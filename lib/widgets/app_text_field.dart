import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool isObscured;
  final VoidCallback? onToggleVisibility;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const AppTextField({
    Key? key,
    required this.label,
    this.hint,
    this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.isObscured = false,
    this.onToggleVisibility,
    this.onChanged,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? hint ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSm(color: AppColors.slateGray),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword && isObscured,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTypography.bodyLg(color: AppColors.deepNavy),
          decoration: InputDecoration(
            hintText: effectiveHint,
            hintStyle: AppTypography.bodyMd(color: AppColors.slateGray.withOpacity(0.6)),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.slateGray, size: 20)
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.slateGray,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.errorRuby : AppColors.outlineVariant,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.errorRuby : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: AppColors.errorRuby),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: AppTypography.labelMd(color: AppColors.errorRuby),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
