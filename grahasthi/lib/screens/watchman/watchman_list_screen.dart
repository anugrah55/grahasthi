import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/watchman_provider.dart';
import 'watchman_tracker_screen.dart';

class WatchmanListScreen extends StatelessWidget {
  const WatchmanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final watchman = context.watch<WatchmanProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t('watchman_tracker'))),
      body: watchman.watchmen.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('💂', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(t('no_watchmen'), style: const TextStyle(color: GrahasthiTheme.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(onPressed: () => _showAddDialog(context), icon: const Icon(Icons.add), label: Text(t('add_watchman'))),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: watchman.watchmen.length,
              itemBuilder: (ctx, i) {
                final w = watchman.watchmen[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: GrahasthiTheme.watchmanIconBg, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('💂', style: TextStyle(fontSize: 24)))),
                    title: Text(w['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('₹${(w['salary'] as num).toInt()}/month', style: const TextStyle(fontSize: 13, color: GrahasthiTheme.textSecondary)),
                    trailing: const Icon(Icons.chevron_right, color: GrahasthiTheme.saffron),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WatchmanTrackerScreen(watchmanId: w['id']))),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context), child: const Icon(Icons.add)),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final salaryController = TextEditingController();
    final t = AppLocalizations.t;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('add_watchman')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameController, decoration: InputDecoration(labelText: t('maid_name'))),
        const SizedBox(height: 12),
        TextField(controller: salaryController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('monthly_salary'))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        ElevatedButton(onPressed: () {
          final name = nameController.text.trim();
          final salary = double.tryParse(salaryController.text) ?? 0;
          if (name.isNotEmpty && salary > 0) { context.read<WatchmanProvider>().addWatchman(name: name, salary: salary); Navigator.pop(ctx); }
        }, child: Text(t('save'))),
      ],
    ));
  }
}
