import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';

class MonthNavigator extends StatelessWidget {
  final int year;
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthNavigator({
    super.key,
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = AppLocalizations.monthName(month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left, color: GrahasthiTheme.saffron),
          iconSize: 28,
        ),
        Text(
          '$monthName $year',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GrahasthiTheme.textPrimary,
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right, color: GrahasthiTheme.saffron),
          iconSize: 28,
        ),
      ],
    );
  }
}
