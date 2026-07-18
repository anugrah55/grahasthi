import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/maid_provider.dart';
import 'maid_tracker_screen.dart';

class MaidListScreen extends StatelessWidget {
  const MaidListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final maid = context.watch<MaidProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t('maid_tracker'))),
      body: maid.maids.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧹', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(t('no_maids'), style: const TextStyle(fontSize: 16, color: GrahasthiTheme.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddMaidDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(t('add_maid')),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: maid.maids.length,
              itemBuilder: (ctx, index) {
                final m = maid.maids[index];
                final net = maid.getNetAmountForMaid(m['id']);
                final days = maid.getEffectiveDaysForMaid(m['id']);

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: GrahasthiTheme.maidIconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('🧹', style: TextStyle(fontSize: 24))),
                    ),
                    title: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${days.toStringAsFixed(days == days.toInt().toDouble() ? 0 : 1)} ${t('total_days')} • ₹${(m['dailyWage'] as num).toInt()}/${AppLocalizations.isHindi ? 'दिन' : 'day'}',
                      style: const TextStyle(color: GrahasthiTheme.textSecondary, fontSize: 13),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(AppLocalizations.formatCurrency(net),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                        Text(t('due'), style: const TextStyle(fontSize: 11, color: GrahasthiTheme.textMuted)),
                      ],
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => MaidTrackerScreen(maidId: m['id']),
                    )),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMaidDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMaidDialog(BuildContext context) {
    final nameController = TextEditingController();
    final wageController = TextEditingController();
    final tasksController = TextEditingController();
    final t = AppLocalizations.t;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('add_maid')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: t('maid_name'))),
            const SizedBox(height: 12),
            TextField(controller: wageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('daily_wage'))),
            const SizedBox(height: 12),
            TextField(controller: tasksController, decoration: InputDecoration(labelText: t('tasks'), hintText: AppLocalizations.isHindi ? 'झाड़ू-पोंछा, बर्तन' : 'Cleaning, Dishes, Cooking')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final wage = double.tryParse(wageController.text) ?? 0;
              if (name.isNotEmpty && wage > 0) {
                context.read<MaidProvider>().addMaid(name: name, dailyWage: wage, tasks: tasksController.text.trim());
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
