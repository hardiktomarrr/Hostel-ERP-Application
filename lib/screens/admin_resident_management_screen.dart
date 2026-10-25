import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_profile_menu.dart';
import 'admin_dashboard_screen.dart';
import 'student_onboarding_screen.dart';

class AdminResidentManagementScreen extends StatefulWidget {
  const AdminResidentManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminResidentManagementScreen> createState() => _AdminResidentManagementScreenState();
}

class _AdminResidentManagementScreenState extends State<AdminResidentManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _checkAndSeedResidents();
  }

  Future<void> _checkAndSeedResidents() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('residents').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        final defaultResidents = [
          {
            'email': 'aarav.sharma@student.com',
            'name': 'Aarav Sharma',
            'room': 'A-102',
            'roomNumber': '102',
            'block': 'Block A',
            'phone': '+91 98765 43210',
            'status': 'Active',
            'roomType': 'Single Premium',
            'rent': '₹12,000',
            'joinDate': 'Jul 01, 2023',
            'leaseEnd': 'Jun 30, 2024',
            'paymentStatus': 'Up to date',
            'dueAmount': 0.0,
            'dueDate': 'No Dues Pending',
            'dueMonth': 'N/A',
            'isOverdue': false,
            'avatar': 'AS',
          },
          {
            'email': 'kabir.mehta@student.com',
            'name': 'Kabir Mehta',
            'room': 'B-304',
            'roomNumber': '304',
            'block': 'Block B',
            'phone': '+91 99887 76655',
            'status': 'Active',
            'roomType': 'Double Standard',
            'rent': '₹8,500',
            'joinDate': 'Aug 15, 2023',
            'leaseEnd': 'May 15, 2024',
            'paymentStatus': 'Pending Dues',
            'dueAmount': 8500.0,
            'dueDate': 'Aug 20, 2023',
            'dueMonth': 'August 2023',
            'isOverdue': false,
            'avatar': 'KM',
          },
          {
            'email': 'rohan.das@student.com',
            'name': 'Rohan Das',
            'room': 'C-215',
            'roomNumber': '215',
            'block': 'Block C',
            'phone': '+91 91234 56789',
            'status': 'Active',
            'roomType': 'Triple Standard',
            'rent': '₹6,000',
            'joinDate': 'Sep 01, 2023',
            'leaseEnd': 'May 31, 2024',
            'paymentStatus': 'Up to date',
            'dueAmount': 0.0,
            'dueDate': 'No Dues Pending',
            'dueMonth': 'N/A',
            'isOverdue': false,
            'avatar': 'RD',
          },
          {
            'email': 'aditya.roy@student.com',
            'name': 'Aditya Roy',
            'room': 'A-208',
            'roomNumber': '208',
            'block': 'Block A',
            'phone': '+91 93456 78901',
            'status': 'Active',
            'roomType': 'Single Standard',
            'rent': '₹10,000',
            'joinDate': 'Oct 01, 2023',
            'leaseEnd': 'Jul 31, 2024',
            'paymentStatus': 'Up to date',
            'dueAmount': 0.0,
            'dueDate': 'No Dues Pending',
            'dueMonth': 'N/A',
            'isOverdue': false,
            'avatar': 'AR',
          },
          {
            'email': 'manish.kumar@student.com',
            'name': 'Manish Kumar',
            'room': 'C-104',
            'roomNumber': '104',
            'block': 'Block C',
            'phone': '+91 95556 66777',
            'status': 'Inactive',
            'roomType': 'Double Standard',
            'rent': '₹8,500',
            'joinDate': 'Jan 10, 2023',
            'leaseEnd': 'Jun 10, 2023',
            'paymentStatus': 'Up to date',
            'dueAmount': 0.0,
            'dueDate': 'No Dues Pending',
            'dueMonth': 'N/A',
            'isOverdue': false,
            'avatar': 'MK',
          },
        ];

        for (final resident in defaultResidents) {
          final docRef = FirebaseFirestore.instance.collection('residents').doc(resident['email'] as String);
          final data = Map<String, dynamic>.from(resident)..remove('email');
          batch.set(docRef, data);
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint("Error seeding residents: $e");
    }
  }

  void _showResidentDetails(Map<String, dynamic> resident, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isPaid = resident['paymentStatus'] == 'Up to date';
        final isActive = resident['status'] == 'Active';

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Details
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      resident['avatar'] ?? 'S',
                      style: AppTypography.headlineSm(color: AppColors.primaryDark).copyWith(
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
                          resident['name'] ?? '',
                          style: AppTypography.headlineMd(color: AppColors.deepNavy).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Room ${resident['room'] ?? 'TBD'} • ${resident['roomType'] ?? 'TBD'}",
                          style: AppTypography.bodyMd(color: AppColors.slateGray),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.successEmerald.withOpacity(0.1)
                          : AppColors.slateGray.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      resident['status'] ?? 'Active',
                      style: AppTypography.labelSm(
                        color: isActive ? AppColors.successEmerald : AppColors.slateGray,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFEBECF0), height: 1),
              const SizedBox(height: 20),

              // Detail Grid
              _buildDetailRow("Email", email),
              _buildDetailRow("Monthly Rent", resident['rent'] ?? '₹0'),
              _buildDetailRow("Join Date", resident['joinDate'] ?? 'TBD'),
              _buildDetailRow("Lease End Date", resident['leaseEnd'] ?? 'TBD'),
              _buildDetailRow("Contact Phone", resident['phone'] ?? 'TBD'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payment Status",
                    style: AppTypography.bodyMd(color: AppColors.slateGray),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.successEmerald.withOpacity(0.1)
                          : AppColors.errorRuby.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      resident['paymentStatus'] ?? 'Up to date',
                      style: AppTypography.labelSm(
                        color: isPaid ? AppColors.successEmerald : AppColors.errorRuby,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Bottom Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Messaging ${resident['name'] ?? ''}...")),
                        );
                      },
                      icon: const Icon(Icons.mail_outline_rounded, size: 18),
                      label: const Text("Message Resident"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showFullProfileDialog(resident, email);
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text("View Full Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showFullProfileDialog(Map<String, dynamic> resident, String email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            resident['name'] ?? '',
            style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detailed ERP Ledger Account", style: AppTypography.labelMd(color: AppColors.primary)),
              const SizedBox(height: 16),
              _buildDialogInfo("Email", email),
              _buildDialogInfo("Assigned Block", resident['block'] ?? 'TBD'),
              _buildDialogInfo("Room Number", resident['roomNumber'] ?? 'TBD'),
              _buildDialogInfo("Room Type", resident['roomType'] ?? 'TBD'),
              _buildDialogInfo("Monthly Ledger Rent", resident['rent'] ?? '₹0'),
              _buildDialogInfo("Contact Phone", resident['phone'] ?? 'TBD'),
              _buildDialogInfo("Status", resident['status'] ?? 'Active'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close Ledger",
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

  Widget _buildDialogInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMd(color: AppColors.slateGray)),
          Text(value, style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMd(color: AppColors.slateGray),
          ),
          Text(
            value,
            style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.deepNavy),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              }
            },
          ),
          title: Text(
            "Resident Management",
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
        drawer: const AdminDrawer(currentRoute: "residents"),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentOnboardingScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar Area
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surfaceWhite,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search residents by name, room, or phone...",
                    hintStyle: AppTypography.bodyMd(color: AppColors.slateGray),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slateGray),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.slateGray),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const Divider(color: Color(0xFFEBECF0), height: 1),

              // Resident List (Real-time Firestore)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('residents').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error fetching residents: ${snapshot.error}",
                          style: AppTypography.bodyMd(color: AppColors.errorRuby),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '').toString().toLowerCase();
                      final room = (data['room'] ?? '').toString().toLowerCase();
                      final phone = (data['phone'] ?? '').toString().toLowerCase();
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || room.contains(query) || phone.contains(query);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline_rounded, color: AppColors.slateGray, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              "No residents found",
                              style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? "Try expanding your search query."
                                  : "Tap + to onboard a new resident.",
                              style: AppTypography.bodyMd(color: AppColors.slateGray),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDocs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final resident = doc.data() as Map<String, dynamic>;
                        final email = doc.id;
                        final isActive = resident['status'] == 'Active';

                        return InkWell(
                          onTap: () => _showResidentDetails(resident, email),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEBECF0), width: 1),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(9, 30, 66, 0.03),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primaryContainer.withOpacity(0.5),
                                  child: Text(
                                    resident['avatar'] ?? 'S',
                                    style: AppTypography.labelSm(color: AppColors.primaryDark).copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resident['name'] ?? '',
                                        style: AppTypography.bodyLg(color: AppColors.deepNavy).copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Room ${resident['room'] ?? 'TBD'} • ${resident['phone'] ?? ''}",
                                        style: AppTypography.labelMd(color: AppColors.slateGray),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.successEmerald.withOpacity(0.1)
                                        : AppColors.slateGray.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    resident['status'] ?? 'Active',
                                    style: AppTypography.labelSm(
                                      color: isActive ? AppColors.successEmerald : AppColors.slateGray,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
