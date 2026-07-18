import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';

class TrackerCard extends StatelessWidget {
  final String emoji;
  final String label;
  final double amount;
  final Color iconBgColor;
  final VoidCallback onTap;

  const TrackerCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.amount,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GrahasthiTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GrahasthiTheme.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Emoji icon with background
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const Spacer(),
              // Label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GrahasthiTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Amount
              Text(
                AppLocalizations.formatCurrency(amount),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: amount > 0 ? GrahasthiTheme.saffron : GrahasthiTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
