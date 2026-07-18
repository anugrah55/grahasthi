import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lpg_provider.dart';

class LpgTrackerScreen extends StatelessWidget {
  const LpgTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final lpg = context.watch<LpgProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t('lpg_tracker'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary cards row
            Row(
              children: [
                Expanded(child: _infoCard('🔥', t('avg_days'), lpg.avgDaysPerCylinder > 0 ? '${lpg.avgDaysPerCylinder.toStringAsFixed(0)} days' : '-')),
                const SizedBox(width: 12),
                Expanded(child: _infoCard('💰', t('annual_spend'), AppLocalizations.formatCurrency(lpg.annualSpend))),
              ],
            ),
            const SizedBox(height: 12),

            // Next reminder
            if (lpg.nextReminderDate != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GrahasthiTheme.saffron.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GrahasthiTheme.saffron.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm, color: GrahasthiTheme.saffron, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${t('next_booking_reminder')}: ${lpg.nextReminderDate!.day}/${lpg.nextReminderDate!.month}/${lpg.nextReminderDate!.year}',
                      style: const TextStyle(fontSize: 13, color: GrahasthiTheme.saffron),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Refill history
            ...lpg.refills.map((refill) => Card(
              child: ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: GrahasthiTheme.lpgIconBg, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('🔥', style: TextStyle(fontSize: 22))),
                ),
                title: Text(AppLocalizations.formatCurrency((refill['amount'] as num).toDouble()),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  refill['date'] ?? '',
                  style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: GrahasthiTheme.textMuted, size: 20),
                  onPressed: () => lpg.deleteRefill(refill['id']),
                ),
              ),
            )),

            if (lpg.refills.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(t('no_refills'), style: const TextStyle(color: GrahasthiTheme.textMuted)),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRefillDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _infoCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GrahasthiTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GrahasthiTheme.cardBorder),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: GrahasthiTheme.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showAddRefillDialog(BuildContext context) {
    final amountController = TextEditingController();
    final deliveryController = TextEditingController();
    final bookingController = TextEditingController();
    final t = AppLocalizations.t;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(t('log_refill')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)),
                      builder: (c, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: GrahasthiTheme.saffron)), child: child!));
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: t('refill_date'), prefixIcon: const Icon(Icons.calendar_today)),
                    child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('amount_paid'))),
                const SizedBox(height: 12),
                TextField(controller: deliveryController, decoration: InputDecoration(labelText: t('delivery_person'))),
                const SizedBox(height: 12),
                TextField(controller: bookingController, decoration: InputDecoration(labelText: t('booking_ref'))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0) {
                  final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                  context.read<LpgProvider>().addRefill(date: dateStr, amount: amount, deliveryPerson: deliveryController.text.trim(), bookingRef: bookingController.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: Text(t('save')),
            ),
          ],
        ),
      ),
    );
  }
}
