import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/admin_drawer.dart';

class StudentOnboardingScreen extends StatefulWidget {
  const StudentOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<StudentOnboardingScreen> createState() => _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends State<StudentOnboardingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _roomNumberCtrl = TextEditingController();
  final TextEditingController _rentCtrl = TextEditingController();
  final TextEditingController _dueAmountCtrl = TextEditingController(text: "0.0");

  String _selectedBlock = "Block A";
  String _selectedRoomType = "Single Standard";
  DateTime _joinDate = DateTime.now();
  DateTime _leaseEndDate = DateTime.now().add(const Duration(days: 365));

  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _roomNumberCtrl.dispose();
    _rentCtrl.dispose();
    _dueAmountCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayStr = date.day.toString().padLeft(2, '0');
    return "${months[date.month - 1]} $dayStr, ${date.year}";
  }

  String _formatDueMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  Future<void> _selectJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _joinDate = picked;
        // Auto update lease end to 1 year after join date
        _leaseEndDate = picked.add(const Duration(days: 365));
      });
    }
  }

  Future<void> _selectLeaseEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _leaseEndDate,
      firstDate: _joinDate,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _leaseEndDate = picked;
      });
    }
  }

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim().toLowerCase();
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final roomNumber = _roomNumberCtrl.text.trim();
    final rent = _rentCtrl.text.trim();
    final dueAmount = double.tryParse(_dueAmountCtrl.text.trim()) ?? 0.0;

    setState(() {
      _isLoading = true;
    });

    try {
      final avatar = name.isNotEmpty
          ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase()
          : 'S';

      // Clean block identifier formatting
      final block = _selectedBlock;
      final roomCode = "${block.substring(block.length - 1)}-$roomNumber";

      final Map<String, dynamic> residentData = {
        'name': name,
        'roomNumber': roomNumber,
        'block': block,
        'room': roomCode,
        'phone': phone,
        'status': 'Active',
        'roomType': _selectedRoomType,
        'rent': '₹$rent',
        'joinDate': _formatDate(_joinDate),
        'leaseEnd': _formatDate(_leaseEndDate),
        'paymentStatus': dueAmount > 0 ? 'Pending Dues' : 'Up to date',
        'dueAmount': dueAmount,
        'dueDate': dueAmount > 0 ? _formatDate(_joinDate.add(const Duration(days: 5))) : 'No Dues Pending',
        'dueMonth': dueAmount > 0 ? _formatDueMonth(_joinDate) : 'N/A',
        'isOverdue': false,
        'avatar': avatar,
        'avatarUrl': 'https://i.pravatar.cc/150?img=${(email.hashCode % 70).abs() + 1}',
      };

      await FirebaseFirestore.instance
          .collection('residents')
          .doc(email)
          .set(residentData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Onboarded student $name successfully!"),
          backgroundColor: AppColors.successEmerald,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to onboard student: $e"),
          backgroundColor: AppColors.errorRuby,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(currentRoute: "onboard_student"),
      appBar: AppBar(
        title: Text(
          "Student Onboarding",
          style: AppTypography.headlineSm(color: Colors.white).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(9, 30, 66, 0.08),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.school_rounded, color: Colors.white, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        "Onboard New Resident",
                        style: AppTypography.headlineSm(color: Colors.white).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Fill out the profile details to register the student in Firestore and provision the resident dashboard credentials.",
                        style: AppTypography.bodyMd(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personal Details",
                        style: AppTypography.bodyLg(color: AppColors.deepNavy).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _nameCtrl,
                        label: "Full Name",
                        hintText: "e.g., Rohan Gupta",
                        prefixIcon: Icons.person_outline_rounded,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailCtrl,
                        label: "Email Address",
                        hintText: "e.g., rohan.gupta@student.com",
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneCtrl,
                        label: "Phone Number",
                        hintText: "e.g., +91 99880 12345",
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone,
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Room & Rent Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hostel Allocation Details",
                        style: AppTypography.bodyLg(color: AppColors.deepNavy).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Block Selection
                      Text(
                        "BLOCK",
                        style: AppTypography.labelSm(color: AppColors.slateGray),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedBlock,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceWhite,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        items: ["Block A", "Block B", "Block C"]
                            .map((b) => DropdownMenuItem(value: b, child: Text(b, style: AppTypography.bodyLg(color: AppColors.deepNavy))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedBlock = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _roomNumberCtrl,
                        label: "Room Number",
                        hintText: "e.g., 105",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.bed_outlined,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      // Room Type
                      Text(
                        "ROOM TYPE",
                        style: AppTypography.labelSm(color: AppColors.slateGray),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedRoomType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceWhite,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        items: ["Single Standard", "Single Premium", "Double Standard", "Triple Standard"]
                            .map((t) => DropdownMenuItem(value: t, child: Text(t, style: AppTypography.bodyLg(color: AppColors.deepNavy))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedRoomType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _rentCtrl,
                        label: "Monthly Rent (₹)",
                        hintText: "e.g., 9000",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments_outlined,
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Schedule & Dues Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Billing & Contract Dates",
                        style: AppTypography.bodyLg(color: AppColors.deepNavy).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dates selectors row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectJoinDate,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.outlineVariant),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "JOIN DATE",
                                      style: AppTypography.labelSm(color: AppColors.slateGray),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatDate(_joinDate),
                                          style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectLeaseEndDate,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.outlineVariant),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "LEASE END",
                                      style: AppTypography.labelSm(color: AppColors.slateGray),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_busy_rounded, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatDate(_leaseEndDate),
                                          style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _dueAmountCtrl,
                        label: "Initial Due Amount (₹)",
                        hintText: "e.g., 0.0 (or outstanding balance)",
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.money_off_rounded,
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                AppButton(
                  text: "Register & Onboard Resident",
                  onPressed: _submitOnboarding,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                  icon: Icons.app_registration_rounded,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
