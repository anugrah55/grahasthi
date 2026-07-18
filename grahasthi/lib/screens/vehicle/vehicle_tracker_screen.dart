import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/vehicle_provider.dart';

class VehicleTrackerScreen extends StatelessWidget {
  const VehicleTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final vehicle = context.watch<VehicleProvider>();
    final mileage = vehicle.getLastMileage();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('vehicle_tracker')),
          bottom: TabBar(
            indicatorColor: GrahasthiTheme.saffron,
            labelColor: GrahasthiTheme.saffron,
            unselectedLabelColor: GrahasthiTheme.textMuted,
            tabs: [Tab(text: t('fuel_fillup')), Tab(text: t('maintenance'))],
          ),
        ),
        body: TabBarView(
          children: [
            // Fuel tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Summary row
                Row(children: [
                  Expanded(child: _infoCard('⛽', t('mileage'), mileage != null ? '${mileage.toStringAsFixed(1)} ${t('km_per_litre')}' : '-')),
                  const SizedBox(width: 12),
                  Expanded(child: _infoCard('💰', t('total_vehicle_spend'), AppLocalizations.formatCurrency(vehicle.annualSpend))),
                ]),
                const SizedBox(height: 16),
                ...vehicle.fuelEntries.map((entry) => Card(
                  child: ListTile(
                    leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: GrahasthiTheme.vehicleIconBg, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('⛽', style: TextStyle(fontSize: 22)))),
                    title: Text('${(entry['litres'] as num).toStringAsFixed(1)}L ${t((entry['fuelType'] as String?) ?? 'petrol')}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${entry['date']} ${((entry['odometer'] as num?)?.toInt() ?? 0) > 0 ? '• ${(entry['odometer'] as num).toInt()} km' : ''}',
                      style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
                    trailing: Text(AppLocalizations.formatCurrency((entry['amount'] as num).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                  ),
                )),
                if (vehicle.fuelEntries.isEmpty) _emptyState('⛽', t('no_fuel_entries')),
              ]),
            ),
            // Maintenance tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                ...vehicle.maintenanceEntries.map((entry) => Card(
                  child: ListTile(
                    leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: GrahasthiTheme.vehicleIconBg, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('🔧', style: TextStyle(fontSize: 22)))),
                    title: Text(entry['type'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${entry['date']} ${(entry['description'] as String? ?? '').isNotEmpty ? '• ${entry['description']}' : ''}',
                      style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
                    trailing: Text(AppLocalizations.formatCurrency((entry['amount'] as num).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                  ),
                )),
                if (vehicle.maintenanceEntries.isEmpty) _emptyState('🔧', AppLocalizations.isHindi ? 'रखरखाव दर्ज करें' : 'Log maintenance'),
              ]),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _infoCard(String emoji, String label, String value) => Container(
    padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: GrahasthiTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: GrahasthiTheme.cardBorder)),
    child: Column(children: [Text(emoji, style: const TextStyle(fontSize: 20)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 11, color: GrahasthiTheme.textMuted), textAlign: TextAlign.center), const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron), textAlign: TextAlign.center)]),
  );

  Widget _emptyState(String emoji, String text) => Padding(padding: const EdgeInsets.only(top: 60), child: Column(children: [Text(emoji, style: const TextStyle(fontSize: 64)), const SizedBox(height: 16), Text(text, style: const TextStyle(color: GrahasthiTheme.textMuted))]));

  void _showAddDialog(BuildContext context) {
    final t = AppLocalizations.t;
    showModalBottomSheet(context: context, backgroundColor: GrahasthiTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: InkWell(
            onTap: () { Navigator.pop(ctx); _showFuelDialog(context); },
            borderRadius: BorderRadius.circular(14),
            child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: GrahasthiTheme.surfaceLight, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [const Text('⛽', style: TextStyle(fontSize: 32)), const SizedBox(height: 8), Text(t('fuel_fillup'), style: const TextStyle(fontWeight: FontWeight.w600))])),
          )),
          const SizedBox(width: 12),
          Expanded(child: InkWell(
            onTap: () { Navigator.pop(ctx); _showMaintenanceDialog(context); },
            borderRadius: BorderRadius.circular(14),
            child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: GrahasthiTheme.surfaceLight, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [const Text('🔧', style: TextStyle(fontSize: 32)), const SizedBox(height: 8), Text(t('maintenance'), style: const TextStyle(fontWeight: FontWeight.w600))])),
          )),
        ]),
      ])));
  }

  void _showFuelDialog(BuildContext context) {
    final litresController = TextEditingController();
    final amountController = TextEditingController();
    final odometerController = TextEditingController();
    String fuelType = 'petrol';
    final t = AppLocalizations.t;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(t('fuel_fillup')),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: fuelType,
            decoration: InputDecoration(labelText: t('fuel_type')),
            items: AppConstants.fuelTypes.map((f) => DropdownMenuItem(value: f, child: Text(t(f)))).toList(),
            onChanged: (val) => setState(() => fuelType = val ?? 'petrol'),
          ),
          const SizedBox(height: 12),
          TextField(controller: litresController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: t('litres_filled'))),
          const SizedBox(height: 12),
          TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('amount'))),
          const SizedBox(height: 12),
          TextField(controller: odometerController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('odometer'))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(onPressed: () {
            final litres = double.tryParse(litresController.text) ?? 0;
            final amount = double.tryParse(amountController.text) ?? 0;
            if (litres > 0 && amount > 0) {
              final dateStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
              context.read<VehicleProvider>().addFuelEntry(date: dateStr, fuelType: fuelType, litres: litres, amount: amount, odometer: double.tryParse(odometerController.text) ?? 0);
              Navigator.pop(ctx);
            }
          }, child: Text(t('save'))),
        ],
      ),
    ));
  }

  void _showMaintenanceDialog(BuildContext context) {
    final typeController = TextEditingController();
    final amountController = TextEditingController();
    final descController = TextEditingController();
    final t = AppLocalizations.t;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('log_maintenance')),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: typeController, decoration: InputDecoration(labelText: t('maintenance_type'))),
        const SizedBox(height: 12),
        TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('amount'))),
        const SizedBox(height: 12),
        TextField(controller: descController, decoration: InputDecoration(labelText: t('description'))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        ElevatedButton(onPressed: () {
          final amount = double.tryParse(amountController.text) ?? 0;
          if (typeController.text.trim().isNotEmpty && amount > 0) {
            final dateStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
            context.read<VehicleProvider>().addMaintenanceEntry(date: dateStr, type: typeController.text.trim(), amount: amount, description: descController.text.trim());
            Navigator.pop(ctx);
          }
        }, child: Text(t('save'))),
      ],
    ));
  }
}
