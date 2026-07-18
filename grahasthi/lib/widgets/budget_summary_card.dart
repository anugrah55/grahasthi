import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double totalExpenses;
  final double monthlyBudget;

  const BudgetSummaryCard({
    super.key,
    required this.totalExpenses,
    required this.monthlyBudget,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final remaining = monthlyBudget - totalExpenses;
    final isOverspent = remaining < 0;
    final progress = monthlyBudget > 0
        ? (totalExpenses / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GrahasthiTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GrahasthiTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                t('how_much_left'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: GrahasthiTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              const Text('✨', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),

          // Total Expenses row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('total_expenses'),
                style: const TextStyle(
                  fontSize: 14,
                  color: GrahasthiTheme.textSecondary,
                ),
              ),
              Text(
                AppLocalizations.formatCurrency(totalExpenses),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: GrahasthiTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Monthly Budget row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('monthly_budget'),
                style: const TextStyle(
                  fontSize: 14,
                  color: GrahasthiTheme.textSecondary,
                ),
              ),
              Text(
                AppLocalizations.formatCurrency(monthlyBudget),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: GrahasthiTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: GrahasthiTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverspent
                    ? GrahasthiTheme.red
                    : progress > 0.8
                        ? GrahasthiTheme.yellow
                        : GrahasthiTheme.green,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOverspent ? t('overspent') : t('remaining'),
                style: const TextStyle(
                  fontSize: 14,
                  color: GrahasthiTheme.textSecondary,
                ),
              ),
              Text(
                AppLocalizations.formatCurrency(remaining.abs()),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isOverspent ? GrahasthiTheme.red : GrahasthiTheme.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
