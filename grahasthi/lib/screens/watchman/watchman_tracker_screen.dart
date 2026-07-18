import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/watchman_provider.dart';
import '../../widgets/monthly_calendar.dart';
import '../../widgets/month_navigator.dart';

class WatchmanTrackerScreen extends StatelessWidget {
  final String watchmanId;
  const WatchmanTrackerScreen({super.key, required this.watchmanId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final watchman = context.watch<WatchmanProvider>();
    final info = watchman.watchmen.firstWhere((w) => w['id'] == watchmanId, orElse: () => {});
    if (info.isEmpty) return Scaffold(appBar: AppBar());

    return Scaffold(
      appBar: AppBar(title: Text(info['name'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          MonthNavigator(year: watchman.selectedYear, month: watchman.selectedMonth, onPrevious: () => watchman.previousMonth(), onNext: () => watchman.nextMonth()),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _legend(GrahasthiTheme.green, t('present')), const SizedBox(width: 12),
            _legend(GrahasthiTheme.red, t('absent')), const SizedBox(width: 12),
            _legend(GrahasthiTheme.yellow, t('half_day')), const SizedBox(width: 12),
            _legend(GrahasthiTheme.blue, t('holiday')),
          ]),
          const SizedBox(height: 12),
          MonthlyCalendar(
            year: watchman.selectedYear, month: watchman.selectedMonth,
            isDayHighlighted: (day) => watchman.getAttendance(watchmanId, day).isNotEmpty,
            dayColor: (day) {
              final s = watchman.getAttendance(watchmanId, day);
              if (s == 'present') return GrahasthiTheme.green;
              if (s == 'absent') return GrahasthiTheme.red;
              if (s == 'half') return GrahasthiTheme.yellow;
              if (s == 'holiday') return GrahasthiTheme.blue;
              return Colors.transparent;
            },
            onDayTap: (day) => _showAttendanceDialog(context, watchman, day),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: GrahasthiTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: GrahasthiTheme.cardBorder)),
            child: Column(children: [
              _row(t('days_present'), '${watchman.getDaysPresent(watchmanId)}'),
              _row(t('half_days'), '${watchman.getHalfDays(watchmanId)}'),
              _row(t('monthly_salary'), AppLocalizations.formatCurrency((info['salary'] as num).toDouble())),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _legend(Color c, String l) => Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 4), Text(l, style: const TextStyle(fontSize: 11, color: GrahasthiTheme.textSecondary))]);
  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: GrahasthiTheme.textSecondary, fontSize: 14)), Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))]));

  void _showAttendanceDialog(BuildContext context, WatchmanProvider watchman, int day) {
    final t = AppLocalizations.t;
    final current = watchman.getAttendance(watchmanId, day);
    showModalBottomSheet(context: context, backgroundColor: GrahasthiTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Day $day', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
        ...['present', 'absent', 'half', 'holiday'].map((s) => ListTile(
          leading: Container(width: 16, height: 16, decoration: BoxDecoration(color: s == 'present' ? GrahasthiTheme.green : s == 'absent' ? GrahasthiTheme.red : s == 'half' ? GrahasthiTheme.yellow : GrahasthiTheme.blue, shape: BoxShape.circle)),
          title: Text(t(s == 'half' ? 'half_day' : s)), trailing: current == s ? const Icon(Icons.check, color: GrahasthiTheme.saffron) : null,
          onTap: () { watchman.setAttendance(watchmanId, day, s); Navigator.pop(ctx); },
        )),
        if (current.isNotEmpty) TextButton(onPressed: () { watchman.setAttendance(watchmanId, day, ''); Navigator.pop(ctx); }, child: Text(t('delete'), style: const TextStyle(color: GrahasthiTheme.red))),
      ])));
  }
}
