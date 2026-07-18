import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/maid_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/monthly_calendar.dart';
import '../../widgets/month_navigator.dart';

class MaidTrackerScreen extends StatelessWidget {
  final String maidId;
  const MaidTrackerScreen({super.key, required this.maidId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final maid = context.watch<MaidProvider>();
    final lang = context.watch<LanguageProvider>().language;
    final info = maid.maids.firstWhere((m) => m['id'] == maidId, orElse: () => {});
    if (info.isEmpty) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Not found')));

    final daysPresent = maid.getDaysPresentForMaid(maidId);
    final halfDays = maid.getHalfDaysForMaid(maidId);
    final effectiveDays = maid.getEffectiveDaysForMaid(maidId);
    final gross = maid.getGrossAmountForMaid(maidId);
    final advance = maid.getTotalAdvanceForMaid(maidId);
    final net = maid.getNetAmountForMaid(maidId);

    return Scaffold(
      appBar: AppBar(
        title: Text(info['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: GrahasthiTheme.saffron),
            onPressed: () => Share.share(maid.getShareTextForMaid(maidId, lang)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month navigator
            MonthNavigator(
              year: maid.selectedYear, month: maid.selectedMonth,
              onPrevious: () => maid.previousMonth(),
              onNext: () => maid.nextMonth(),
            ),
            const SizedBox(height: 8),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend(GrahasthiTheme.green, t('present')),
                const SizedBox(width: 12),
                _legend(GrahasthiTheme.red, t('absent')),
                const SizedBox(width: 12),
                _legend(GrahasthiTheme.yellow, t('half_day')),
                const SizedBox(width: 12),
                _legend(GrahasthiTheme.blue, t('holiday')),
              ],
            ),
            const SizedBox(height: 12),

            // Calendar
            MonthlyCalendar(
              year: maid.selectedYear,
              month: maid.selectedMonth,
              isDayHighlighted: (day) => maid.getAttendance(maidId, day).isNotEmpty,
              dayColor: (day) {
                final status = maid.getAttendance(maidId, day);
                switch (status) {
                  case 'present': return GrahasthiTheme.green;
                  case 'absent': return GrahasthiTheme.red;
                  case 'half': return GrahasthiTheme.yellow;
                  case 'holiday': return GrahasthiTheme.blue;
                  default: return Colors.transparent;
                }
              },
              dayBuilder: (day) {
                final status = maid.getAttendance(maidId, day);
                Color dotColor = Colors.transparent;
                if (status == AppConstants.statusPresent) dotColor = GrahasthiTheme.green;
                else if (status == AppConstants.statusAbsent) dotColor = GrahasthiTheme.red;
                else if (status == AppConstants.statusHalfDay) dotColor = GrahasthiTheme.yellow;
                else if (status == AppConstants.statusHoliday) dotColor = GrahasthiTheme.blue;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$day', style: TextStyle(fontSize: 13, color: GrahasthiTheme.textPrimary)),
                    if (dotColor != Colors.transparent)
                      Container(
                        width: 6, height: 6, margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                      ),
                  ],
                );
              },
              onDayTap: (day) => _showAttendanceDialog(context, maid, day),
            ),
            const SizedBox(height: 20),

            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GrahasthiTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GrahasthiTheme.cardBorder),
              ),
              child: Column(
                children: [
                  _summaryRow(t('days_present'), '$daysPresent'),
                  if (halfDays > 0) _summaryRow(t('half_days'), '$halfDays'),
                  _summaryRow(t('total_days'), '${effectiveDays.toStringAsFixed(effectiveDays == effectiveDays.toInt().toDouble() ? 0 : 1)}'),
                  const Divider(height: 16),
                  _summaryRow('${t('total_days')} × ₹${(info['dailyWage'] as num).toInt()}', AppLocalizations.formatCurrency(gross)),
                  if (advance > 0) ...[
                    _summaryRow(t('advance_paid'), '-${AppLocalizations.formatCurrency(advance)}',
                      valueColor: GrahasthiTheme.red),
                  ],
                  const Divider(height: 16),
                  _summaryRow(t('amount_due'), AppLocalizations.formatCurrency(net),
                    labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    valueColor: GrahasthiTheme.saffron, valueFontSize: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Advance section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t('advance_paid'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: () => _showAddAdvanceDialog(context, maid),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(t('add_advance')),
                ),
              ],
            ),
            ...maid.getAdvancesForMaid(maidId).map((adv) => ListTile(
              dense: true,
              leading: const Icon(Icons.money_off, color: GrahasthiTheme.red, size: 20),
              title: Text(AppLocalizations.formatCurrency((adv['amount'] as num).toDouble()),
                style: const TextStyle(color: GrahasthiTheme.red)),
              subtitle: Text(adv['note'] ?? '', style: const TextStyle(fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: GrahasthiTheme.textMuted),
                onPressed: () => maid.deleteAdvance(adv['key']),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: GrahasthiTheme.textSecondary)),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor, double? valueFontSize, TextStyle? labelStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle ?? const TextStyle(fontSize: 14, color: GrahasthiTheme.textSecondary)),
          Text(value, style: TextStyle(fontSize: valueFontSize ?? 14, fontWeight: FontWeight.w600, color: valueColor ?? GrahasthiTheme.textPrimary)),
        ],
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context, MaidProvider maid, int day) {
    final t = AppLocalizations.t;
    final current = maid.getAttendance(maidId, day);

    showModalBottomSheet(
      context: context,
      backgroundColor: GrahasthiTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Day $day', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...[
              _attendanceOption(ctx, maid, day, AppConstants.statusPresent, t('present'), GrahasthiTheme.green, current),
              _attendanceOption(ctx, maid, day, AppConstants.statusAbsent, t('absent'), GrahasthiTheme.red, current),
              _attendanceOption(ctx, maid, day, AppConstants.statusHalfDay, t('half_day'), GrahasthiTheme.yellow, current),
              _attendanceOption(ctx, maid, day, AppConstants.statusHoliday, t('holiday'), GrahasthiTheme.blue, current),
            ],
            const SizedBox(height: 8),
            if (current.isNotEmpty)
              TextButton(
                onPressed: () {
                  maid.setAttendance(maidId, day, '');
                  Navigator.pop(ctx);
                },
                child: Text(t('delete'), style: const TextStyle(color: GrahasthiTheme.red)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _attendanceOption(BuildContext ctx, MaidProvider maid, int day, String status, String label, Color color, String current) {
    return ListTile(
      leading: Container(
        width: 16, height: 16,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(label),
      trailing: current == status ? const Icon(Icons.check, color: GrahasthiTheme.saffron) : null,
      onTap: () {
        maid.setAttendance(maidId, day, status);
        Navigator.pop(ctx);
      },
    );
  }

  void _showAddAdvanceDialog(BuildContext context, MaidProvider maid) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final t = AppLocalizations.t;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('add_advance')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('advance_amount'))),
            const SizedBox(height: 12),
            TextField(controller: noteController, decoration: InputDecoration(labelText: t('note'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                maid.addAdvance(maidId, amount, noteController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }
}
