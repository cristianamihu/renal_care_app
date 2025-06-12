import 'package:flutter/material.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';

/// Callback apelat când utilizatorul selectează o zi
typedef OnDateSelected = void Function(DateTime date);

/// Afișează un calendar orizontal
class WeeklyCalendar extends StatefulWidget {
  final DateTime initialSelectedDate;
  final OnDateSelected onDateSelected;

  const WeeklyCalendar({
    super.key,
    required this.initialSelectedDate,
    required this.onDateSelected,
  });

  @override
  WeeklyCalendarState createState() => WeeklyCalendarState();
}

class WeeklyCalendarState extends State<WeeklyCalendar> {
  late DateTime selectedDate;
  int weekOffset =
      0; // 0 = săptămâna curentă, -1 = săptămâna trecută, +1 = săptămâna viitoare

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialSelectedDate;
  }

  /// Prima zi de luni a săptămânii date de weekOffset
  DateTime get _startOfWeek {
    final mondayThisWeek = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - DateTime.monday),
    );
    return mondayThisWeek.add(Duration(days: 7 * weekOffset));
  }

  @override
  Widget build(BuildContext context) {
    final start = _startOfWeek;
    final days = List.generate(7, (i) => start.add(Duration(days: i)));

    // Calculează label-ul de dedesubt
    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final String label =
        isToday
            ? 'Azi, ${selectedDate.day} ${_monthAbbr(selectedDate.month)}'
            : '${_weekdayAbbr(selectedDate.weekday)}, ${selectedDate.day} ${_monthAbbr(selectedDate.month)}';

    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  setState(() {
                    weekOffset--;
                  });
                },
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      days.map((d) {
                        final bool isToday =
                            d.year == selectedDate.year &&
                            d.month == selectedDate.month &&
                            d.day == selectedDate.day;

                        final String weekdayAbbr = _weekdayAbbr(d.weekday);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = d;
                            });
                            widget.onDateSelected(d);
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
                                      isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
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
                                        isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  setState(() {
                    weekOffset++;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Afișează textul de tip "Azi, 6 iun."
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
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
    const names = [
      'ian.',
      'feb.',
      'mar.',
      'apr.',
      'mai',
      'iun.',
      'iul.',
      'aug.',
      'sep.',
      'oct.',
      'nov.',
      'dec.',
    ];
    return names[month - 1];
  }
}
