import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/festival_provider.dart';

class FestivalDetailScreen extends StatelessWidget {
  final String festivalId;
  const FestivalDetailScreen({super.key, required this.festivalId});

  static const _categories = ['decorations', 'gifts', 'sweets', 'clothes', 'puja_items', 'travel', 'catering', 'fest_other'];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final festival = context.watch<FestivalProvider>();
    final info = festival.festivals.firstWhere((f) => f['id'] == festivalId, orElse: () => {});
    if (info.isEmpty) return Scaffold(appBar: AppBar());

    final budget = (info['totalBudget'] as num).toDouble();
    final spent = festival.getTotalSpentForFestival(festivalId);
    final remaining = budget - spent;
    final expenses = festival.getExpensesForFestival(festivalId);
    final isActive = info['isActive'] != false;

    return Scaffold(
      appBar: AppBar(
        title: Text(info['name']),
        actions: [
          if (isActive) PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'history') festival.moveFestivalToHistory(festivalId);
              if (val == 'delete') _confirmDelete(context, festival);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'history', child: Text(t('move_to_history'))),
              PopupMenuItem(value: 'delete', child: Text(t('delete'), style: const TextStyle(color: GrahasthiTheme.red))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Budget overview
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: GrahasthiTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: GrahasthiTheme.cardBorder)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('budget_used'), style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
                  Text(AppLocalizations.formatCurrency(spent), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(t('budget_remaining'), style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
                  Text(AppLocalizations.formatCurrency(remaining.abs()), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: remaining >= 0 ? GrahasthiTheme.green : GrahasthiTheme.red)),
                ]),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0, minHeight: 8, backgroundColor: GrahasthiTheme.surfaceLight,
                  valueColor: AlwaysStoppedAnimation(remaining < 0 ? GrahasthiTheme.red : GrahasthiTheme.green))),
              const SizedBox(height: 4),
              Text('${t('total_budget')}: ${AppLocalizations.formatCurrency(budget)}', style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
            ]),
          ),
          const SizedBox(height: 16),

          // Expenses list
          ...expenses.map((exp) => Dismissible(
            key: Key(exp['key']),
            direction: DismissDirection.endToStart,
            background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: GrahasthiTheme.red)),
            onDismissed: (_) => festival.deleteExpense(exp['key']),
            child: Card(child: ListTile(
              leading: const Text('🎁', style: TextStyle(fontSize: 20)),
              title: Text(exp['item'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(t(exp['category'] ?? 'fest_other'), style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
              trailing: Text(AppLocalizations.formatCurrency((exp['amount'] as num).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
            )),
          )),

          if (expenses.isEmpty)
            Padding(padding: const EdgeInsets.only(top: 40), child: Text(t('no_entries'), style: const TextStyle(color: GrahasthiTheme.textMuted))),
        ]),
      ),
      floatingActionButton: isActive ? FloatingActionButton(onPressed: () => _showAddExpenseDialog(context), child: const Icon(Icons.add)) : null,
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final itemController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'fest_other';
    final t = AppLocalizations.t;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(t('add_expense_item')),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: itemController, decoration: InputDecoration(labelText: t('item_name'))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: category,
            decoration: InputDecoration(labelText: t('expense_category')),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(t(c)))).toList(),
            onChanged: (val) => setState(() => category = val ?? 'fest_other'),
          ),
          const SizedBox(height: 12),
          TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('amount'))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(onPressed: () {
            final amount = double.tryParse(amountController.text) ?? 0;
            if (itemController.text.trim().isNotEmpty && amount > 0) {
              context.read<FestivalProvider>().addExpense(festivalId, category: category, item: itemController.text.trim(), amount: amount);
              Navigator.pop(ctx);
            }
          }, child: Text(t('save'))),
        ],
      ),
    ));
  }

  void _confirmDelete(BuildContext context, FestivalProvider festival) {
    final t = AppLocalizations.t;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('delete')),
      content: Text(t('confirm_delete')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: GrahasthiTheme.red),
          onPressed: () { festival.deleteFestival(festivalId); Navigator.pop(ctx); Navigator.pop(context); },
          child: Text(t('delete'))),
      ],
    ));
  }
}
