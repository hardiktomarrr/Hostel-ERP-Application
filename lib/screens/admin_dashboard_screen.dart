import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_profile_menu.dart';
import 'admin_pending_payments_screen.dart';
import 'admin_resident_management_screen.dart';
import 'admin_schedules_screen.dart';
import 'onboarding_screen.dart';
import 'student_onboarding_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription? _ticketsSub;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _dbTickets = [];
  int _openTicketsCount = 0;

  @override
  void initState() {
    super.initState();
    _ticketsSub = FirebaseFirestore.instance
        .collection('tickets')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _dbTickets = snapshot.docs;
          // Sort descending by document ID
          _dbTickets.sort((a, b) => b.id.compareTo(a.id));
          _openTicketsCount = _dbTickets.where((doc) {
            final status =
                (doc.data()['status'] ?? '').toString().toLowerCase();
            return status == 'open' || status == 'in progress';
          }).length;
        });
      }
    });
  }

  @override
  void dispose() {
    _ticketsSub?.cancel();
    super.dispose();
  }

  void _showStatusUpdateDialog(
      String docId, String currentStatus, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Update Ticket Status",
            style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Update status for: \"$title\" ($docId)",
                style: AppTypography.bodyMd(color: AppColors.slateGray),
              ),
              const SizedBox(height: 16),
              ...['Open', 'In Progress', 'Resolved', 'Closed']
                  .map((statusOption) {
                final isSelected =
                    statusOption.toLowerCase() == currentStatus.toLowerCase();
                return ListTile(
                  title: Text(
                    statusOption,
                    style: AppTypography.bodyLg(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.deepNavy)
                        .copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () {
                    FirebaseFirestore.instance
                        .collection('tickets')
                        .doc(docId)
                        .update({
                      'status': statusOption,
                    }).then((_) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("Ticket status updated to $statusOption!"),
                          backgroundColor: AppColors.successEmerald,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    });
                  },
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: AppTypography.bodyMd(color: AppColors.slateGray)),
            ),
          ],
        );
      },
    );
  }

  void _postAnnouncementDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    bool isImportant = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Post Announcement",
                style: AppTypography.headlineSm(color: AppColors.deepNavy)
                    .copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Publish a new notification to all hostellers.",
                      style: AppTypography.bodyMd(color: AppColors.slateGray),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Announcement Title",
                        hintText: "e.g., Water supply maintenance",
                        labelStyle:
                            AppTypography.bodyMd(color: AppColors.slateGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Details / Message",
                        hintText:
                            "e.g., Water supply will be suspended on Saturday morning...",
                        labelStyle:
                            AppTypography.bodyMd(color: AppColors.slateGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: isImportant,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setDialogState(() {
                              isImportant = val ?? false;
                            });
                          },
                        ),
                        Text(
                          "Mark as Important / Urgent",
                          style: AppTypography.bodyMd(color: AppColors.deepNavy)
                              .copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: AppTypography.bodyMd(color: AppColors.slateGray),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final desc = descController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Title cannot be empty")),
                      );
                      return;
                    }

                    final id = "ANN-${DateTime.now().millisecondsSinceEpoch}";
                    FirebaseFirestore.instance
                        .collection('announcements')
                        .doc(id)
                        .set({
                      'title': title,
                      'description': desc,
                      'timeAgo': 'Just now',
                      'isImportant': isImportant,
                      'timestamp': FieldValue.serverTimestamp(),
                    }).then((_) {
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Announcement published successfully${isImportant ? ' (Urgent)' : ''}!",
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.successEmerald,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }).catchError((error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to publish: $error"),
                            backgroundColor: AppColors.errorRuby,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Publish",
                    style: AppTypography.bodyMd(color: Colors.white).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAllTicketsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Support Tickets",
                    style: AppTypography.headlineSm(color: AppColors.deepNavy)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${_dbTickets.length} Total",
                    style: AppTypography.labelMd(color: AppColors.slateGray),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 380,
                child: _dbTickets.isEmpty
                    ? Center(
                        child: Text(
                          "No support tickets filed yet.",
                          style:
                              AppTypography.bodyMd(color: AppColors.slateGray),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _dbTickets.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final doc = _dbTickets[index];
                          return _buildTicketRow(doc);
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Close",
                    style:
                        AppTypography.bodyMd(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTicketRow(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final ticket = doc.data();
    final String docId = doc.id;
    final String title = ticket['title'] ?? 'Maintenance Request';
    final String reportedBy = ticket['reportedBy'] ?? 'Unknown';
    final String reporter = reportedBy.split('@').first;
    final String date = ticket['date'] ?? 'Today';
    final String priority = ticket['priority'] ?? 'Low';
    final String category = ticket['category'] ?? 'Others';
    final String status = ticket['status'] ?? 'Open';

    Color priorityColor;
    Color priorityBg;
    switch (priority) {
      case 'Critical':
      case 'High':
        priorityColor = AppColors.errorRuby;
        priorityBg = AppColors.errorRuby.withOpacity(0.1);
        break;
      case 'Medium':
        priorityColor = AppColors.warningAmber;
        priorityBg = AppColors.warningAmber.withOpacity(0.1);
        break;
      case 'Low':
      default:
        priorityColor = AppColors.slateGray;
        priorityBg = AppColors.slateGray.withOpacity(0.1);
        break;
    }

    IconData categoryIcon;
    switch (category) {
      case 'Plumbing':
        categoryIcon = Icons.plumbing_rounded;
        break;
      case 'WiFi':
      case 'IT Support':
        categoryIcon = Icons.wifi_rounded;
        break;
      case 'Cleaning':
      case 'Housekeeping':
        categoryIcon = Icons.cleaning_services_rounded;
        break;
      case 'Electrical':
        categoryIcon = Icons.electrical_services_rounded;
        break;
      case 'Carpentry':
      default:
        categoryIcon = Icons.build_rounded;
        break;
    }

    return InkWell(
      onTap: () => _showStatusUpdateDialog(docId, status, title),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(categoryIcon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMd(color: AppColors.deepNavy)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "By $reporter • $date • $status",
                    style: AppTypography.labelMd(color: AppColors.slateGray),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                priority,
                style: AppTypography.labelSm(color: priorityColor).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Admin Dashboard",
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
      drawer: const AdminDrawer(currentRoute: "dashboard"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Overview",
                              style: AppTypography.headlineMd(
                                      color: AppColors.deepNavy)
                                  .copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Monitor property operations, payments, and tickets.",
                              style: AppTypography.bodyMd(
                                  color: AppColors.slateGray),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats Cards Row
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: "Pending Payments",
                              value: "14",
                              badgeText: "Needs Action",
                              badgeColor: AppColors.errorRuby,
                              icon: Icons.pending_actions_rounded,
                              onTap: () =>
                                  Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminPendingPaymentsScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: "Open Tickets",
                              value: _openTicketsCount.toString(),
                              badgeText: "High Priority",
                              badgeColor: AppColors.warningAmber,
                              icon: Icons.report_problem_rounded,
                              onTap: _showAllTicketsDialog,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: "Total Residents",
                              value: "120",
                              badgeText: "Stable",
                              badgeColor: AppColors.successEmerald,
                              icon: Icons.people_rounded,
                              onTap: () =>
                                  Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminResidentManagementScreen()),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildStatCard(
                            title: "Pending Payments",
                            value: "14",
                            badgeText: "Needs Action",
                            badgeColor: AppColors.errorRuby,
                            icon: Icons.pending_actions_rounded,
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminPendingPaymentsScreen()),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            title: "Open Tickets",
                            value: _openTicketsCount.toString(),
                            badgeText: "High Priority",
                            badgeColor: AppColors.warningAmber,
                            icon: Icons.report_problem_rounded,
                            onTap: _showAllTicketsDialog,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            title: "Total Residents",
                            value: "120",
                            badgeText: "Stable",
                            badgeColor: AppColors.successEmerald,
                            icon: Icons.people_rounded,
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminResidentManagementScreen()),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Quick Actions Section
                    Text(
                      "Quick Actions",
                      style: AppTypography.headlineSm(color: AppColors.deepNavy)
                          .copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionsRow(isDesktop),
                    const SizedBox(height: 32),

                    // Recent Tickets Section Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFEBECF0), width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(9, 30, 66, 0.04),
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
                                "Recent Support Tickets",
                                style: AppTypography.headlineSm(
                                        color: AppColors.deepNavy)
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: _showAllTicketsDialog,
                                child: Text(
                                  "View All",
                                  style: AppTypography.bodyMd(
                                          color: AppColors.primary)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFEBECF0)),
                          const SizedBox(height: 16),
                          _dbTickets.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Center(
                                    child: Text(
                                      "No support tickets filed yet.",
                                      style: AppTypography.bodyMd(
                                          color: AppColors.slateGray),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _dbTickets.length > 3
                                      ? 3
                                      : _dbTickets.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final doc = _dbTickets[index];
                                    return _buildTicketRow(doc);
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBECF0), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(9, 30, 66, 0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMd(color: AppColors.slateGray)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: AppTypography.headlineLg(color: AppColors.deepNavy)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: AppTypography.labelSm(color: badgeColor).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(bool isDesktop) {
    final actions = [
      {
        'label': 'Verify Payments',
        'icon': Icons.verified_user_rounded,
        'screen': const AdminPendingPaymentsScreen(),
      },
      {
        'label': 'Manage Residents',
        'icon': Icons.manage_accounts_rounded,
        'screen': const AdminResidentManagementScreen(),
      },
      {
        'label': 'Update Schedules',
        'icon': Icons.restaurant_menu_rounded,
        'screen': const AdminSchedulesScreen(),
      },
      {
        'label': 'Onboard Student',
        'icon': Icons.person_add_alt_1_rounded,
        'screen': const StudentOnboardingScreen(),
      },
      {
        'label': 'Preview Onboarding',
        'icon': Icons.preview_rounded,
        'screen': const OnboardingScreen(isPreview: true),
      },
      {
        'label': 'Post Announcement',
        'icon': Icons.campaign_rounded,
        'action': _postAnnouncementDialog,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isDesktop ? 3.0 : 2.2,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _buildQuickActionButton(actions[index]);
      },
    );
  }

  Widget _buildQuickActionButton(Map<String, dynamic> act) {
    return ElevatedButton(
      onPressed: () {
        if (act['screen'] != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => act['screen'] as Widget),
          );
        } else if (act['action'] != null) {
          (act['action'] as VoidCallback)();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.deepNavy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFEBECF0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(act['icon'] as IconData, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              act['label'] as String,
              style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
