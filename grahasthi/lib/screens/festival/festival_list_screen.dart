import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/festival_provider.dart';
import 'festival_detail_screen.dart';

class FestivalListScreen extends StatelessWidget {
  const FestivalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final festival = context.watch<FestivalProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t('festival_tracker'))),
      body: festival.festivals.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(t('no_festivals'), style: const TextStyle(color: GrahasthiTheme.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(onPressed: () => _showAddDialog(context), icon: const Icon(Icons.add), label: Text(t('add_occasion'))),
            ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (festival.activeFestivals.isNotEmpty) ...[
                  Text(t('active_events'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                  const SizedBox(height: 8),
                  ...festival.activeFestivals.map((f) => _festivalCard(context, festival, f)),
                ],
                if (festival.pastFestivals.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(t('past_events'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GrahasthiTheme.textMuted)),
                  const SizedBox(height: 8),
                  ...festival.pastFestivals.map((f) => _festivalCard(context, festival, f, isPast: true)),
                ],
              ]),
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context), child: const Icon(Icons.add)),
    );
  }

  Widget _festivalCard(BuildContext context, FestivalProvider festival, Map<String, dynamic> f, {bool isPast = false}) {
    final budget = (f['totalBudget'] as num).toDouble();
    final spent = festival.getTotalSpentForFestival(f['id']);
    final remaining = budget - spent;
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FestivalDetailScreen(festivalId: f['id']))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('🎉', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPast ? GrahasthiTheme.textMuted : GrahasthiTheme.textPrimary)),
                Text(f['date'] ?? '', style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(AppLocalizations.formatCurrency(spent), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                Text('/ ${AppLocalizations.formatCurrency(budget)}', style: const TextStyle(fontSize: 11, color: GrahasthiTheme.textMuted)),
              ]),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: GrahasthiTheme.surfaceLight,
                valueColor: AlwaysStoppedAnimation(remaining < 0 ? GrahasthiTheme.red : GrahasthiTheme.green)),
            ),
          ]),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    final t = AppLocalizations.t;
    DateTime selectedDate = DateTime.now();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(t('add_occasion')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: InputDecoration(labelText: t('occasion_name'))),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
                builder: (c, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: GrahasthiTheme.saffron)), child: child!));
              if (picked != null) setDialogState(() => selectedDate = picked);
            },
            child: InputDecorator(decoration: InputDecoration(labelText: t('occasion_date'), prefixIcon: const Icon(Icons.calendar_today)),
              child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}')),
          ),
          const SizedBox(height: 12),
          TextField(controller: budgetController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('total_budget'))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(onPressed: () {
            final name = nameController.text.trim();
            final budget = double.tryParse(budgetController.text) ?? 0;
            if (name.isNotEmpty && budget > 0) {
              final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
              context.read<FestivalProvider>().addFestival(name: name, date: dateStr, totalBudget: budget);
              Navigator.pop(ctx);
            }
          }, child: Text(t('save'))),
        ],
      ),
    ));
  }
}
