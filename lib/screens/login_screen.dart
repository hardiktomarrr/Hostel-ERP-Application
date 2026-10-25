import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import '../models/user_role.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/app_checkbox.dart';
import '../widgets/app_text_field.dart';
import '../widgets/brand_header.dart';
import '../widgets/desktop_hero_banner.dart';
import '../widgets/role_selector.dart';
import 'resident_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';


class LoginScreen extends StatefulWidget {
  final UserRole? initialRole;
  const LoginScreen({Key? key, this.initialRole}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _controller;
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
    if (widget.initialRole != null) {
      _controller.setRole(widget.initialRole!);
    }
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final success = await _controller.login();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                "Welcome back! Logged in as ${_controller.selectedRole.label}.",
              ),
            ],
          ),
          backgroundColor: AppColors.successEmerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      if (_controller.selectedRole == UserRole.owner) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResidentDashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;

            if (isDesktop) {
              return Row(
                children: [
                  const Expanded(
                    flex: 5,
                    child: DesktopHeroBanner(),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: AppColors.background,
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: _buildFormCard(isDesktop: true),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Mobile view layout
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildFormCard(isDesktop: false),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormCard({required bool isDesktop}) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 36 : 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Branding Header
          BrandHeader(isCompact: !isDesktop),
          const SizedBox(height: 28),

          // Role Selector (Resident vs Owner)
          RoleSelector(
            selectedRole: _controller.selectedRole,
            onRoleChanged: (role) => _controller.setRole(role),
          ),
          const SizedBox(height: 20),

          // Error Banner if validation fails
          if (_controller.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorRuby.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.errorRuby.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: AppColors.errorRuby),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.errorMessage!,
                      style: AppTypography.bodyMd(color: AppColors.errorRuby),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email Address Input
          AppTextField(
            label: "Email Address",
            hint: _controller.selectedRole == UserRole.resident
                ? "Enter your predefined user email"
                : "Enter your predefined manager email",
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _identifierController,
            onChanged: (val) => _controller.setIdentifier(val),
          ),
          const SizedBox(height: 16),

          // Password Input
          AppTextField(
            label: "Password",
            hint: "Enter your password",
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            isObscured: !_controller.isPasswordVisible,
            onToggleVisibility: () => _controller.togglePasswordVisibility(),
            controller: _passwordController,
            onChanged: (val) => _controller.setPassword(val),
          ),
          const SizedBox(height: 14),

          // Remember Me & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppCheckbox(
                value: _controller.rememberMe,
                onChanged: (val) => _controller.toggleRememberMe(val),
                label: "Remember me",
              ),
              AppButton(
                text: "Forgot password?",
                type: ButtonType.text,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Please contact your Hostel Admin or Resident Warden to reset password.",
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Login Primary Action Button
          AppButton(
            text: _controller.selectedRole == UserRole.resident
                ? "Sign In as User"
                : "Sign In as Manager",
            isLoading: _controller.isLoading,
            icon: Icons.arrow_forward_rounded,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 24),

          // Divider with text
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "NEED HELP?",
                  style: AppTypography.labelSm(color: AppColors.slateGray),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.outlineVariant)),
            ],
          ),
          const SizedBox(height: 16),

          // Contact Support Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline_rounded, size: 16, color: AppColors.slateGray),
              const SizedBox(width: 6),
              Text(
                "Having trouble logging in? ",
                style: AppTypography.bodyMd(color: AppColors.slateGray),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Support Helpdesk: support@lakshyahostels.com | +91 98765 43210",
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                child: Text(
                  "Contact Support",
                  style: AppTypography.bodyMd(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
