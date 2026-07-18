import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/grocery_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/month_navigator.dart';
import 'add_grocery_screen.dart';

class GroceryTrackerScreen extends StatelessWidget {
  const GroceryTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final grocery = context.watch<GroceryProvider>();
    final lang = context.watch<LanguageProvider>().language;
    final items = grocery.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('grocery_tracker')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: GrahasthiTheme.saffron),
            onPressed: () => Share.share(grocery.getShareText(lang)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month nav + total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                MonthNavigator(
                  year: grocery.selectedYear, month: grocery.selectedMonth,
                  onPrevious: () => grocery.previousMonth(),
                  onNext: () => grocery.nextMonth(),
                ),
                const SizedBox(height: 8),
                // Monthly total card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GrahasthiTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GrahasthiTheme.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t('monthly_total'), style: const TextStyle(fontSize: 15, color: GrahasthiTheme.textSecondary)),
                      Text(AppLocalizations.formatCurrency(grocery.monthlyTotal),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Category breakdown chips
                if (grocery.categoryTotals.isNotEmpty)
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: grocery.categoryTotals.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(
                            '${AppLocalizations.categoryName(e.key)} ₹${e.value.toInt()}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: _getCategoryColor(e.key).withOpacity(0.2),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Items list
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(t('no_entries'), style: const TextStyle(color: GrahasthiTheme.textMuted)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      final catColor = _getCategoryColor(item['category']);
                      return Dismissible(
                        key: Key(item['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: GrahasthiTheme.red),
                        ),
                        onDismissed: (_) => grocery.deleteItem(item['id']),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              width: 4, height: 40,
                              decoration: BoxDecoration(
                                color: catColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(
                              '${AppLocalizations.categoryName(item['category'])} • ${item['date']?.toString().substring(5) ?? ''}',
                              style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted),
                            ),
                            trailing: Text(
                              AppLocalizations.formatCurrency((item['amount'] as num).toDouble()),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: GrahasthiTheme.saffron),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGroceryScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'sabzi': return GrahasthiTheme.catVegetables;
      case 'fruits': return GrahasthiTheme.catFruits;
      case 'dairy': return GrahasthiTheme.catDairy;
      case 'grains': return GrahasthiTheme.catGrains;
      case 'spices': return GrahasthiTheme.catSpices;
      case 'cleaning': return GrahasthiTheme.catCleaning;
      case 'personal': return GrahasthiTheme.catPersonal;
      case 'medicines': return GrahasthiTheme.catMedicine;
      case 'snacks': return GrahasthiTheme.catSnacks;
      default: return GrahasthiTheme.catOther;
    }
  }
}
