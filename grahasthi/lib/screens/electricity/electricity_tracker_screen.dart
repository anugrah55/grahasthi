import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/electricity_provider.dart';

class ElectricityTrackerScreen extends StatelessWidget {
  const ElectricityTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final elec = context.watch<ElectricityProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t('electricity_tracker'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // High usage alert
            if (elec.isHighUsage)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: GrahasthiTheme.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: GrahasthiTheme.red.withOpacity(0.3))),
                child: Text(t('high_usage_alert'), style: const TextStyle(fontSize: 13, color: GrahasthiTheme.red)),
              ),

            // Consumer info
            if (elec.consumerNumber.isNotEmpty || elec.discomName.isNotEmpty)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: GrahasthiTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: GrahasthiTheme.cardBorder)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (elec.discomName.isNotEmpty) Text('DISCOM: ${elec.discomName}', style: const TextStyle(fontSize: 13, color: GrahasthiTheme.textSecondary)),
                  if (elec.consumerNumber.isNotEmpty) Text('${t('consumer_number')}: ${elec.consumerNumber}', style: const TextStyle(fontSize: 13, color: GrahasthiTheme.textSecondary)),
                ]),
              ),

            // Settings button
            TextButton.icon(
              onPressed: () => _showSettingsDialog(context, elec),
              icon: const Icon(Icons.settings, size: 18),
              label: Text('${t('consumer_number')} / DISCOM'),
            ),
            const SizedBox(height: 8),

            // Bills list
            ...elec.bills.map((bill) {
              final units = (bill['units'] as num).toDouble();
              final amount = (bill['billAmount'] as num).toDouble();
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: GrahasthiTheme.electricityIconBg, borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('⚡', style: TextStyle(fontSize: 22))),
                  ),
                  title: Text('${units.toInt()} ${t('units_consumed')}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(bill['date'] ?? '', style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
                  trailing: Text(AppLocalizations.formatCurrency(amount), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                ),
              );
            }),

            if (elec.bills.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(children: [
                  const Text('⚡', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(t('no_bills'), style: const TextStyle(color: GrahasthiTheme.textMuted)),
                ]),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddBillDialog(context), child: const Icon(Icons.add)),
    );
  }

  void _showSettingsDialog(BuildContext context, ElectricityProvider elec) {
    final consumerController = TextEditingController(text: elec.consumerNumber);
    final discomController = TextEditingController(text: elec.discomName);
    final rateController = TextEditingController(text: elec.perUnitRate > 0 ? elec.perUnitRate.toString() : '');
    final t = AppLocalizations.t;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('settings_title')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: consumerController, decoration: InputDecoration(labelText: t('consumer_number'))),
        const SizedBox(height: 12),
        TextField(controller: discomController, decoration: InputDecoration(labelText: t('discom_name'))),
        const SizedBox(height: 12),
        TextField(controller: rateController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: t('per_unit_rate'))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        ElevatedButton(onPressed: () {
          elec.saveSettings(consumerNumber: consumerController.text.trim(), discomName: discomController.text.trim(), perUnitRate: double.tryParse(rateController.text) ?? 0);
          Navigator.pop(ctx);
        }, child: Text(t('save'))),
      ],
    ));
  }

  void _showAddBillDialog(BuildContext context) {
    final prevController = TextEditingController();
    final currController = TextEditingController();
    final amountController = TextEditingController();
    final t = AppLocalizations.t;
    DateTime selectedDate = DateTime.now();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(t('electricity_tracker')),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 30)),
                builder: (c, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: GrahasthiTheme.saffron)), child: child!));
              if (picked != null) setDialogState(() => selectedDate = picked);
            },
            child: InputDecorator(decoration: InputDecoration(labelText: t('date'), prefixIcon: const Icon(Icons.calendar_today)),
              child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}')),
          ),
          const SizedBox(height: 12),
          TextField(controller: prevController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('prev_reading'))),
          const SizedBox(height: 12),
          TextField(controller: currController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('curr_reading'))),
          const SizedBox(height: 12),
          TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('bill_amount'))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(onPressed: () {
            final prev = double.tryParse(prevController.text) ?? 0;
            final curr = double.tryParse(currController.text) ?? 0;
            final amount = double.tryParse(amountController.text) ?? 0;
            if (curr > prev && amount > 0) {
              final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
              context.read<ElectricityProvider>().addBill(date: dateStr, prevReading: prev, currReading: curr, billAmount: amount);
              Navigator.pop(ctx);
            }
          }, child: Text(t('save'))),
        ],
      ),
    ));
  }
}
