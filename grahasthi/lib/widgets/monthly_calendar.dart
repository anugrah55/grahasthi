import 'package:flutter/material.dart';
import '../config/theme.dart';

class MonthlyCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Widget Function(int day)? dayBuilder;
  final void Function(int day)? onDayTap;
  final bool Function(int day)? isDayHighlighted;
  final Color Function(int day)? dayColor;

  const MonthlyCalendar({
    super.key,
    required this.year,
    required this.month,
    this.dayBuilder,
    this.onDayTap,
    this.isDayHighlighted,
    this.dayColor,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon, 7=Sun
    // Monday-first calendar: Mon=0, Tue=1, ..., Sun=6
    final startOffset = firstWeekday - 1;

    final dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Column(
      children: [
        // Day labels row
        Row(
          children: dayLabels.map((d) {
            return Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GrahasthiTheme.textMuted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        ...List.generate(6, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - startOffset + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return Expanded(child: SizedBox(height: 46));
                }

                final isToday = DateTime.now().year == year &&
                    DateTime.now().month == month &&
                    DateTime.now().day == dayNumber;

                final highlighted = isDayHighlighted?.call(dayNumber) ?? false;
                final color = dayColor?.call(dayNumber);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDayTap?.call(dayNumber),
                    child: Container(
                      height: 46,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: highlighted
                            ? (color ?? GrahasthiTheme.saffron).withOpacity(0.15)
                            : isToday
                                ? GrahasthiTheme.surfaceLight
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday
                            ? Border.all(color: GrahasthiTheme.saffron, width: 1.5)
                            : null,
                      ),
                      child: dayBuilder != null
                          ? dayBuilder!(dayNumber)
                          : Center(
                              child: Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  color: isToday
                                      ? GrahasthiTheme.saffron
                                      : GrahasthiTheme.textPrimary,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}
