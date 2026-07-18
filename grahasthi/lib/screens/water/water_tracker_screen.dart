import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/water_provider.dart';
import '../../widgets/month_navigator.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final water = context.watch<WaterProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t('water_tracker'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MonthNavigator(year: water.selectedYear, month: water.selectedMonth, onPrevious: () => water.previousMonth(), onNext: () => water.nextMonth()),
            const SizedBox(height: 12),
            // Monthly total
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: GrahasthiTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: GrahasthiTheme.cardBorder)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(t('monthly_total'), style: const TextStyle(color: GrahasthiTheme.textSecondary)),
                Text(AppLocalizations.formatCurrency(water.monthlyTotal), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
              ]),
            ),
            const SizedBox(height: 16),
            // Entries
            ...water.entries.map((entry) {
              final isCan = entry['type'] == 'can';
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: GrahasthiTheme.waterIconBg, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(isCan ? '💧' : '🚛', style: const TextStyle(fontSize: 22))),
                  ),
                  title: Text(isCan ? '${entry['numCans']} ${t('water_can')}' : '${entry['tankerSize']}KL ${t('water_tanker')}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(entry['date'] ?? '', style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
                  trailing: Text(AppLocalizations.formatCurrency((entry['totalAmount'] as num).toDouble()),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                ),
              );
            }),
            if (water.entries.isEmpty)
              Padding(padding: const EdgeInsets.only(top: 60), child: Column(children: [
                const Text('💧', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(t('no_water_entries'), style: const TextStyle(color: GrahasthiTheme.textMuted)),
              ])),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final t = AppLocalizations.t;
    showModalBottomSheet(
      context: context, backgroundColor: GrahasthiTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(t('log_delivery'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _deliveryOption(ctx, '💧', t('water_can'), () { Navigator.pop(ctx); _showCanDialog(context); })),
            const SizedBox(width: 12),
            Expanded(child: _deliveryOption(ctx, '🚛', t('water_tanker'), () { Navigator.pop(ctx); _showTankerDialog(context); })),
          ]),
        ]),
      ),
    );
  }

  Widget _deliveryOption(BuildContext ctx, String emoji, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: GrahasthiTheme.surfaceLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: GrahasthiTheme.cardBorder)),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  void _showCanDialog(BuildContext context) {
    final cansController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    final t = AppLocalizations.t;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('water_can')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: cansController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('num_cans'))),
        const SizedBox(height: 12),
        TextField(controller: priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('price_per_can'))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        ElevatedButton(onPressed: () {
          final cans = int.tryParse(cansController.text) ?? 0;
          final price = double.tryParse(priceController.text) ?? 0;
          if (cans > 0 && price > 0) {
            final dateStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
            context.read<WaterProvider>().addCanDelivery(date: dateStr, numCans: cans, pricePerCan: price);
            Navigator.pop(ctx);
          }
        }, child: Text(t('save'))),
      ],
    ));
  }

  void _showTankerDialog(BuildContext context) {
    final sizeController = TextEditingController();
    final amountController = TextEditingController();
    final t = AppLocalizations.t;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('water_tanker')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: sizeController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: t('tanker_size'))),
        const SizedBox(height: 12),
        TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('amount'))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        ElevatedButton(onPressed: () {
          final size = double.tryParse(sizeController.text) ?? 0;
          final amount = double.tryParse(amountController.text) ?? 0;
          if (size > 0 && amount > 0) {
            final dateStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
            context.read<WaterProvider>().addTankerDelivery(date: dateStr, tankerSize: size, amount: amount);
            Navigator.pop(ctx);
          }
        }, child: Text(t('save'))),
      ],
    ));
  }
}
