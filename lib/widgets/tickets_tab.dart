import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SupportTicket {
  final String id;
  final String category;
  final String title;
  final String description;
  final String roomBlock;
  final String priority; // "Low", "Medium", "High"
  final String status; // "Open", "In Progress", "Resolved", "Closed"
  final String date;
  final String? attachmentName;

  SupportTicket({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.roomBlock,
    required this.priority,
    required this.status,
    required this.date,
    this.attachmentName,
  });
}

class TicketsTab extends StatefulWidget {
  const TicketsTab({Key? key}) : super(key: key);

  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  final List<SupportTicket> _tickets = [];
  StreamSubscription? _ticketsSubscription;

  @override
  void initState() {
    super.initState();
    _initTicketsStream();
  }

  void _initTicketsStream() {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'unknown@lakshya.com';
    _ticketsSubscription = FirebaseFirestore.instance
        .collection('tickets')
        .where('reportedBy', isEqualTo: email)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        _seedDefaultUserTickets();
        return;
      }
      final List<SupportTicket> loaded = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        loaded.add(SupportTicket(
          id: doc.id,
          category: data['category'] ?? 'Others',
          title: data['title'] ?? 'Support Ticket',
          description: data['description'] ?? '',
          roomBlock: data['roomBlock'] ?? '',
          priority: data['priority'] ?? 'Low',
          status: data['status'] ?? 'Open',
          date: data['date'] ?? '',
          attachmentName: data['attachmentName'],
        ));
      }
      // Sort loaded tickets locally by date/ID descending if needed, or by timestamp
      loaded.sort((a, b) => b.id.compareTo(a.id));
      if (mounted) {
        setState(() {
          _tickets.clear();
          _tickets.addAll(loaded);
        });
      }
    });
  }

  Future<void> _seedDefaultUserTickets() async {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'unknown@lakshya.com';
    final batch = FirebaseFirestore.instance.batch();

    final List<Map<String, dynamic>> defaultSeeds = [
      {
        'id': 'TKT-4921',
        'category': 'Plumbing',
        'title': 'Leaking Faucet',
        'description': 'The tap in bathroom A-102 is leaking constantly. Needs urgent fixing as water is wasting.',
        'roomBlock': 'A-102',
        'priority': 'High',
        'status': 'Open',
        'date': 'Oct 24, 2023',
        'reportedBy': email,
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'id': 'TKT-4890',
        'category': 'WiFi',
        'title': 'Slow Internet',
        'description': 'Wi-Fi on the 3rd floor is extremely slow during evening hours.',
        'roomBlock': '3rd Floor',
        'priority': 'Medium',
        'status': 'In Progress',
        'date': 'Oct 22, 2023',
        'reportedBy': email,
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'id': 'TKT-4712',
        'category': 'Electrical',
        'title': 'Broken Study Lamp Socket',
        'description': 'The study lamp socket is not giving power output, tried other devices too.',
        'roomBlock': 'A-102',
        'priority': 'Low',
        'status': 'Resolved',
        'date': 'Oct 18, 2023',
        'reportedBy': email,
        'timestamp': FieldValue.serverTimestamp(),
      },
    ];

    for (var seed in defaultSeeds) {
      final docRef = FirebaseFirestore.instance.collection('tickets').doc(seed['id']);
      batch.set(docRef, seed);
    }
    await batch.commit();
  }

  final _descriptionController = TextEditingController();
  final _roomController = TextEditingController();
  String _selectedPriority = "Low"; // "Low", "Medium", "High"
  bool _hasAttachment = false;
  String? _descriptionError;
  String? _roomError;
  String _activeFilter = "Open"; // "Open", "In Progress", "Resolved", "Closed"

  @override
  void dispose() {
    _ticketsSubscription?.cancel();
    _descriptionController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _submitTicket() {
    final description = _descriptionController.text.trim();
    final room = _roomController.text.trim();

    setState(() {
      _descriptionError = description.isEmpty ? "Please describe the issue" : null;
      _roomError = room.isEmpty ? "Please enter your room or block number" : null;
    });

    if (description.isEmpty || room.isEmpty) {
      return;
    }

    // Auto-generate title and category based on description keywords
    String title = "Maintenance Request";
    String category = "Others";
    final descLower = description.toLowerCase();

    if (descLower.contains("leak") || descLower.contains("tap") || descLower.contains("faucet") || descLower.contains("water") || descLower.contains("plumb")) {
      title = "Leaking Faucet";
      category = "Plumbing";
    } else if (descLower.contains("wifi") || descLower.contains("internet") || descLower.contains("slow") || descLower.contains("connection")) {
      title = "WiFi Connection issue";
      category = "WiFi";
    } else if (descLower.contains("bulb") || descLower.contains("light") || descLower.contains("power") || descLower.contains("socket") || descLower.contains("electric")) {
      title = "Electrical Issue";
      category = "Electrical";
    } else if (descLower.contains("clean") || descLower.contains("dust") || descLower.contains("dirt") || descLower.contains("sweep") || descLower.contains("waste")) {
      title = "Cleaning Issue";
      category = "Cleaning";
    } else {
      final words = description.split(' ');
      if (words.isNotEmpty) {
        title = words.take(3).join(' ');
        if (title.length > 20) {
          title = "${title.substring(0, 17)}...";
        }
      }
    }

    final randomId = "TKT-${1000 + Random().nextInt(9000)}";
    final email = FirebaseAuth.instance.currentUser?.email ?? 'unknown@lakshya.com';

    final ticketData = {
      'category': category,
      'title': title,
      'description': description,
      'roomBlock': room,
      'priority': _selectedPriority,
      'status': 'Open',
      'date': 'Oct 25, 2023',
      'reportedBy': email,
      'attachmentName': _hasAttachment ? "ticket_receipt_photo.png" : null,
      'timestamp': FieldValue.serverTimestamp(),
    };

    FirebaseFirestore.instance.collection('tickets').doc(randomId).set(ticketData).then((_) {
      if (mounted) {
        setState(() {
          _descriptionController.clear();
          _roomController.clear();
          _selectedPriority = "Low";
          _hasAttachment = false;
          _activeFilter = "Open";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ticket $randomId submitted for verification!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.successEmerald,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit ticket: $error"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.errorRuby,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter tickets according to active tab
    final filteredTickets = _tickets.where((ticket) {
      return ticket.status.toLowerCase() == _activeFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Raise a Ticket Card
                  _buildRaiseTicketCard(),
                  const SizedBox(height: 32),

                  // My Tickets Header
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        color: AppColors.deepNavy,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "My Tickets",
                        style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter Pills Row
                  _buildFilterPillsRow(),
                  const SizedBox(height: 16),

                  // Tickets List
                  filteredTickets.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTickets.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildTicketCard(filteredTickets[index]);
                          },
                        ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRaiseTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(
                Icons.local_play_outlined,
                color: Color(0xFF0049B0),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                "Raise a Ticket",
                style: AppTypography.headlineSm(color: AppColors.deepNavy).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description label & text field
          Text(
            "Description",
            style: AppTypography.labelSm(color: AppColors.slateGray).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            style: AppTypography.bodyLg(color: AppColors.deepNavy),
            decoration: InputDecoration(
              hintText: "Describe the issue...",
              hintStyle: AppTypography.bodyLg(color: AppColors.slateGray.withOpacity(0.5)),
              errorText: _descriptionError,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFEBECF0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFEBECF0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0049B0), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Room/Block label & text field
          Text(
            "Room/Block",
            style: AppTypography.labelSm(color: AppColors.slateGray).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _roomController,
            style: AppTypography.bodyLg(color: AppColors.deepNavy),
            decoration: InputDecoration(
              hintText: "e.g., A-102",
              hintStyle: AppTypography.bodyLg(color: AppColors.slateGray.withOpacity(0.5)),
              errorText: _roomError,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFEBECF0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFEBECF0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0049B0), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Priority label & segmented buttons
          Text(
            "Priority",
            style: AppTypography.labelSm(color: AppColors.slateGray).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildPriorityButton("Low")),
              const SizedBox(width: 8),
              Expanded(child: _buildPriorityButton("Medium")),
              const SizedBox(width: 8),
              Expanded(child: _buildPriorityButton("High")),
            ],
          ),
          const SizedBox(height: 16),

          // Attach Photo label & dashed container
          Text(
            "Attach photo/video (Optional)",
            style: AppTypography.labelSm(color: AppColors.slateGray).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildAttachmentUploader(),
          const SizedBox(height: 24),

          // Submit button
          ElevatedButton(
            onPressed: _submitTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0049B0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              "Submit Ticket",
              style: AppTypography.bodyLg(color: Colors.white).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityButton(String label) {
    final isSelected = _selectedPriority.toLowerCase() == label.toLowerCase();
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = label;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE9F2FF) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF0049B0) : const Color(0xFFDFE1E6),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.bodyLg(
            color: isSelected ? const Color(0xFF0049B0) : AppColors.slateGray,
          ).copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentUploader() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _hasAttachment = !_hasAttachment;
        });
      },
      child: CustomPaint(
        painter: DashedRectPainter(
          color: _hasAttachment ? AppColors.successEmerald : const Color(0xFFC4C9D3),
          strokeWidth: 1.5,
          gap: 4,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _hasAttachment 
                ? AppColors.successEmerald.withOpacity(0.04) 
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                _hasAttachment ? Icons.task_alt_rounded : Icons.backup_outlined,
                color: _hasAttachment ? AppColors.successEmerald : const Color(0xFF0049B0),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                _hasAttachment ? "ticket_receipt_photo.png" : "Tap to upload",
                style: AppTypography.bodyMd(
                  color: _hasAttachment ? AppColors.successEmerald : AppColors.slateGray,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPillsRow() {
    final filters = ["Open", "In Progress", "Resolved", "Closed"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _activeFilter.toLowerCase() == filter.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeFilter = filter;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0049B0) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0049B0) : const Color(0xFFDFE1E6),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: AppTypography.bodyMd(
                    color: isSelected ? Colors.white : AppColors.slateGray,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    // Determine status badge colors
    Color statusBgColor = const Color(0xFFF4F5F7);
    Color statusTextColor = const Color(0xFF5E6C84);
    if (ticket.status.toLowerCase() == 'open') {
      statusBgColor = const Color(0xFFFFF9E6);
      statusTextColor = const Color(0xFFFF8B00);
    } else if (ticket.status.toLowerCase() == 'in progress') {
      statusBgColor = const Color(0xFFDEEBFF);
      statusTextColor = const Color(0xFF0747A6);
    } else if (ticket.status.toLowerCase() == 'resolved') {
      statusBgColor = const Color(0xFFE3FCEF);
      statusTextColor = const Color(0xFF006644);
    }

    // Determine left border color based on priority & status
    Color indicatorColor = const Color(0xFFDFE1E6);
    if (ticket.status.toLowerCase() == 'resolved' || ticket.status.toLowerCase() == 'closed') {
      indicatorColor = AppColors.successEmerald;
    } else if (ticket.priority.toLowerCase() == 'high') {
      indicatorColor = AppColors.errorRuby;
    } else if (ticket.priority.toLowerCase() == 'medium') {
      indicatorColor = AppColors.warningAmber;
    } else {
      indicatorColor = const Color(0xFF0049B0);
    }

    // Determine category icon
    IconData categoryIcon = Icons.build_outlined;
    if (ticket.category.toLowerCase() == 'wifi') {
      categoryIcon = Icons.wifi_rounded;
    } else if (ticket.category.toLowerCase() == 'plumbing') {
      categoryIcon = Icons.handyman_outlined;
    } else if (ticket.category.toLowerCase() == 'electrical') {
      categoryIcon = Icons.flash_on_outlined;
    } else if (ticket.category.toLowerCase() == 'cleaning') {
      categoryIcon = Icons.cleaning_services_outlined;
    }

    // Determine priority icon and colors in footer
    Color priorityColor = AppColors.slateGray;
    IconData priorityIcon = Icons.info_outline_rounded;
    if (ticket.priority.toLowerCase() == 'high') {
      priorityColor = AppColors.errorRuby;
      priorityIcon = Icons.priority_high_rounded;
    } else if (ticket.priority.toLowerCase() == 'medium') {
      priorityColor = AppColors.warningAmber;
      priorityIcon = Icons.remove_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left indicator line
              Container(
                width: 5,
                color: indicatorColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Category Icon, Title, and Status Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            categoryIcon,
                            color: const Color(0xFF42526E),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ticket.title,
                              style: AppTypography.bodyLg(color: AppColors.deepNavy).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ticket.status.toUpperCase(),
                              style: TextStyle(
                                color: statusTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        ticket.description,
                        style: AppTypography.bodyMd(color: AppColors.slateGray),
                      ),
                      const SizedBox(height: 16),

                      // Footer Row: Date and Priority
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ticket.date,
                            style: AppTypography.bodyMd(color: AppColors.slateGray).copyWith(
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                priorityIcon,
                                color: priorityColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ticket.priority,
                                style: TextStyle(
                                  color: priorityColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBECF0)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            color: AppColors.slateGray.withOpacity(0.4),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            "No $_activeFilter Tickets",
            style: AppTypography.bodyLg(color: AppColors.deepNavy).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "All caught up in this category!",
            style: AppTypography.bodyMd(color: AppColors.slateGray),
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    ));

    final Path dashedPath = Path();
    double distance = 0.0;
    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
