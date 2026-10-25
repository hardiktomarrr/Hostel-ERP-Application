import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_profile_menu.dart';
import 'admin_dashboard_screen.dart';

class AdminPendingPaymentsScreen extends StatefulWidget {
  const AdminPendingPaymentsScreen({Key? key}) : super(key: key);

  @override
  State<AdminPendingPaymentsScreen> createState() => _AdminPendingPaymentsScreenState();
}

class _AdminPendingPaymentsScreenState extends State<AdminPendingPaymentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedMonth = "October 2023";

  final List<String> _months = [
    "October 2023",
    "September 2023",
    "August 2023",
  ];

  // Mock list of pending payments
  late List<Map<String, String>> _pendingPayments;

  @override
  void initState() {
    super.initState();
    _pendingPayments = [
      {
        'id': '1',
        'name': 'Aarav Sharma',
        'room': 'A-102',
        'amount': '₹4,500',
        'utr': '329847109283',
        'date': 'Oct 10, 2023',
        'month': 'October 2023',
      },
      {
        'id': '2',
        'name': 'Kabir Mehta',
        'room': 'B-304',
        'amount': '₹6,200',
        'utr': '847291038472',
        'date': 'Oct 11, 2023',
        'month': 'October 2023',
      },
      {
        'id': '3',
        'name': 'Rohan Das',
        'room': 'C-215',
        'amount': '₹4,500',
        'utr': '109847289104',
        'date': 'Oct 12, 2023',
        'month': 'October 2023',
      },
      {
        'id': '4',
        'name': 'Aditya Roy',
        'room': 'A-208',
        'amount': '₹5,100',
        'utr': '501938472810',
        'date': 'Oct 13, 2023',
        'month': 'October 2023',
      },
      {
        'id': '5',
        'name': 'Vikram Singh',
        'room': 'B-108',
        'amount': '₹4,500',
        'utr': '778899001122',
        'date': 'Sep 15, 2023',
        'month': 'September 2023',
      },
      {
        'id': '6',
        'name': 'Devansh Gupta',
        'room': 'C-301',
        'amount': '₹4,800',
        'utr': '445566332211',
        'date': 'Aug 14, 2023',
        'month': 'August 2023',
      },
    ];
  }

  void _handleApprove(Map<String, String> payment) {
    setState(() {
      _pendingPayments.removeWhere((p) => p['id'] == payment['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text("Approved payment of ${payment['amount']} from ${payment['name']}."),
          ],
        ),
        backgroundColor: AppColors.successEmerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleReject(Map<String, String> payment) {
    setState(() {
      _pendingPayments.removeWhere((p) => p['id'] == payment['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text("Rejected payment of ${payment['amount']} from ${payment['name']}."),
          ],
        ),
        backgroundColor: AppColors.errorRuby,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter payments based on selected month
    final filteredPayments = _pendingPayments
        .where((p) => p['month'] == _selectedMonth)
        .toList();

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
            "Pending Payments",
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
        drawer: const AdminDrawer(currentRoute: "payments"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Title & Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Verify Transactions",
                                style: AppTypography.headlineMd(color: AppColors.deepNavy).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Review and approve manual bank transfers & UPI payments.",
                                style: AppTypography.bodyMd(color: AppColors.slateGray),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEBECF0), width: 1),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedMonth,
                                items: _months.map((m) {
                                  return DropdownMenuItem<String>(
                                    value: m,
                                    child: Text(
                                      m,
                                      style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedMonth = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Payments List
                      if (filteredPayments.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEBECF0)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.successEmerald.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppColors.successEmerald,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "All Caught Up!",
                                style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "No pending payments found for $_selectedMonth.",
                                style: AppTypography.bodyMd(color: AppColors.slateGray),
                              ),
                            ],
                          ),
                        )
                      else if (isDesktop)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: filteredPayments.length,
                          itemBuilder: (context, index) {
                            return _buildPaymentCard(filteredPayments[index]);
                          },
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredPayments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildPaymentCard(filteredPayments[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildPaymentCard(Map<String, String> payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
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
          // Name & Room Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment['name']!,
                      style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Room ${payment['room']} • ${payment['date']}",
                      style: AppTypography.labelMd(color: AppColors.slateGray),
                    ),
                  ],
                ),
              ),
              Text(
                payment['amount']!,
                style: AppTypography.headlineSm(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // UTR Details Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  "UTR: ",
                  style: AppTypography.labelMd(color: AppColors.slateGray).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  payment['utr']!,
                  style: AppTypography.bodyMd(color: AppColors.deepNavy).copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Reject / Approve Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _handleReject(payment),
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text("Reject"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorRuby,
                  side: const BorderSide(color: AppColors.errorRuby),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _handleApprove(payment),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text("Approve"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
