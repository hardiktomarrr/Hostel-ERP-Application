import 'package:flutter/material.dart';
import '../models/resident_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class NextCabCard extends StatelessWidget {
  final ShuttleInfo shuttle;
  final VoidCallback onBookSeat;

  const NextCabCard({
    Key? key,
    required this.shuttle,
    required this.onBookSeat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF8338EC); // Purple accent for Cab Section
    final bool isUnavailable =
        shuttle.departureTime == "No upcoming cab" ||
        shuttle.departureTime == "N/A";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBECF0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(9, 30, 66, 0.04),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Purple left accent border bar
              Container(
                width: 4,
                color: accentColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon container with matching light background
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_taxi_rounded,
                          size: 20,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Upcoming Shuttle",
                                  style: AppTypography.headlineSm(
                                          color: AppColors.deepNavy)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isUnavailable
                                        ? const Color(0xFFFFEBEB)
                                        : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isUnavailable ? "Closed" : shuttle.status,
                                    style: AppTypography.labelSm(
                                            color: isUnavailable
                                                ? AppColors.errorRuby
                                                : const Color(0xFF2E7D32))
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isUnavailable
                                  ? "No Upcoming Cab"
                                  : shuttle.departureTime,
                              style: AppTypography.headlineLg(
                                      color: isUnavailable
                                          ? AppColors.slateGray
                                          : AppColors.deepNavy)
                                  .copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!isUnavailable) ...[
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 14, color: AppColors.slateGray),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      shuttle.destination,
                                      style: AppTypography.bodyMd(
                                              color: AppColors.slateGray)
                                          .copyWith(
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.event_seat_outlined,
                                          size: 14, color: AppColors.slateGray),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${shuttle.availableSeats} seats left",
                                        style: AppTypography.bodyMd(
                                                color: AppColors.slateGray)
                                            .copyWith(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: onBookSeat,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      backgroundColor:
                                          accentColor.withOpacity(0.08),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      "Book Seat",
                                      style: AppTypography.labelSm(
                                              color: accentColor)
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      size: 14, color: AppColors.slateGray),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "All scheduled cabs have departed for today.",
                                      style: AppTypography.bodyMd(
                                              color: AppColors.slateGray)
                                          .copyWith(
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
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
}
