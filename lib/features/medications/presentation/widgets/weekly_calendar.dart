import 'package:flutter/material.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';

/// Afișează un calendar orizontal pe o săptămână (Luni–Duminică),
/// cu ziua curentă evidențiată.
class WeeklyCalendar extends StatefulWidget {
  const WeeklyCalendar({super.key});

  @override
  WeeklyCalendarState createState() => WeeklyCalendarState();
}

class WeeklyCalendarState extends State<WeeklyCalendar> {
  DateTime selectedDate = DateTime.now();

  /// Returnează Data de luni din săptămâna curentă
  DateTime get _startOfWeek {
    final now = DateTime.now();
    final int diff = now.weekday - DateTime.monday; // DateTime.monday = 1
    final monday = now.subtract(Duration(days: diff));
    return DateTime(monday.year, monday.month, monday.day);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime weekStart = _startOfWeek;

    // Construim lista de 7 zile (luni → duminică)
    final List<DateTime> days = List<DateTime>.generate(
      7,
      (i) => weekStart.add(Duration(days: i)),
    );

    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                days.map((d) {
                  final bool isToday =
                      d.year == today.year &&
                      d.month == today.month &&
                      d.day == today.day;

                  final String weekdayAbbr = _weekdayAbbr(d.weekday);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = d;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weekdayAbbr,
                          style: TextStyle(
                            color:
                                isToday
                                    ? AppColors.gradient3
                                    : AppColors.whiteColor.withValues(
                                      alpha: 0.6,
                                    ),
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration:
                              isToday
                                  ? const BoxDecoration(
                                    color: AppColors.gradient3,
                                    shape: BoxShape.circle,
                                  )
                                  : null,
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '${d.day}',
                            style: TextStyle(
                              color:
                                  isToday
                                      ? Colors.white
                                      : AppColors.whiteColor.withValues(
                                        alpha: 0.6,
                                      ),
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 4),
          // Afișează textul de tip "Azi, 6 iun."
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Azi, ${today.day} ${_monthAbbr(today.month)}',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayAbbr(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'lun.';
      case DateTime.tuesday:
        return 'mar.';
      case DateTime.wednesday:
        return 'mie.';
      case DateTime.thursday:
        return 'joi';
      case DateTime.friday:
        return 'vin.';
      case DateTime.saturday:
        return 'sâm.';
      case DateTime.sunday:
        return 'dum.';
      default:
        return '';
    }
  }

  String _monthAbbr(int month) {
    switch (month) {
      case 1:
        return 'ian.';
      case 2:
        return 'feb.';
      case 3:
        return 'mar.';
      case 4:
        return 'apr.';
      case 5:
        return 'mai';
      case 6:
        return 'iun.';
      case 7:
        return 'iul.';
      case 8:
        return 'aug.';
      case 9:
        return 'sep.';
      case 10:
        return 'oct.';
      case 11:
        return 'nov.';
      case 12:
        return 'dec.';
      default:
        return '';
    }
  }
}
