import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/milk_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/monthly_calendar.dart';
import '../../widgets/month_navigator.dart';

class MilkTrackerScreen extends StatelessWidget {
  const MilkTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final milk = context.watch<MilkProvider>();
    final lang = context.watch<LanguageProvider>().language;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('milk_tracker')),
        actions: [
          if (milk.milkTypes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share, color: GrahasthiTheme.saffron),
              onPressed: () => Share.share(milk.getShareText(lang)),
            ),
        ],
      ),
      body: milk.milkTypes.isEmpty
          ? _buildEmptyState(context, t)
          : _buildContent(context, milk, t, lang),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMilkTypeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String Function(String) t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🥛', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            t('no_milk_types'),
            style: const TextStyle(fontSize: 16, color: GrahasthiTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddMilkTypeDialog(context),
            icon: const Icon(Icons.add),
            label: Text(t('add_milk_type')),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, MilkProvider milk, String Function(String) t, String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigator
          MonthNavigator(
            year: milk.selectedYear,
            month: milk.selectedMonth,
            onPrevious: () => milk.previousMonth(),
            onNext: () => milk.nextMonth(),
          ),
          const SizedBox(height: 12),

          // Milk type tabs
          ...milk.milkTypes.map((type) => _buildMilkTypeSection(context, milk, type)),

          const SizedBox(height: 16),

          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GrahasthiTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GrahasthiTheme.cardBorder),
            ),
            child: Column(
              children: [
                Text(
                  '🥛 ${t('milk_tracker')}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem(t('total_litres'), '${milk.totalLitresThisMonth}L'),
                    _summaryItem(t('total_amount'), AppLocalizations.formatCurrency(milk.totalAmountThisMonth)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkTypeSection(BuildContext context, MilkProvider milk, Map<String, dynamic> type) {
    final typeId = type['id'] as String;
    final typeName = type['name'] as String;
    final price = (type['pricePerLitre'] as num).toDouble();
    final defaultQty = (type['defaultQty'] as num?)?.toDouble() ?? 1.0;
    final t = AppLocalizations.t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type header with edit/delete
        Row(
          children: [
            Text(
              typeName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: GrahasthiTheme.saffron),
            ),
            const SizedBox(width: 8),
            Text('₹${price.toInt()}/L', style: const TextStyle(fontSize: 13, color: GrahasthiTheme.textSecondary)),
            const Spacer(),
            PopupMenuButton<String>(
              iconSize: 20,
              icon: const Icon(Icons.more_vert, color: GrahasthiTheme.textMuted, size: 20),
              onSelected: (val) {
                if (val == 'edit') _showEditMilkTypeDialog(context, type);
                if (val == 'delete') _confirmDeleteType(context, typeId);
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(AppLocalizations.t('edit'))),
                PopupMenuItem(value: 'delete', child: Text(AppLocalizations.t('delete'))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmSetDefaultForMonth(context, milk, typeId, typeName, defaultQty),
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(t('set_default_for_month')),
            style: OutlinedButton.styleFrom(
              foregroundColor: GrahasthiTheme.saffron,
              side: const BorderSide(color: GrahasthiTheme.saffron),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Calendar
        MonthlyCalendar(
          year: milk.selectedYear,
          month: milk.selectedMonth,
          isDayHighlighted: (day) => milk.hasLoggedEntryForDay(day, typeId),
          dayColor: (day) {
            if (milk.isNoMilkDay(day, typeId)) return GrahasthiTheme.red;
            if (milk.getLitresForDay(day, typeId) > 0) return GrahasthiTheme.blue;
            return Colors.transparent;
          },
          dayBuilder: (day) {
            final litres = milk.getLitresForDay(day, typeId);
            final noMilk = milk.isNoMilkDay(day, typeId);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: litres > 0 || noMilk ? FontWeight.bold : FontWeight.normal,
                    color: DateTime.now().day == day && DateTime.now().month == milk.selectedMonth && DateTime.now().year == milk.selectedYear
                        ? GrahasthiTheme.saffron
                        : GrahasthiTheme.textPrimary,
                  ),
                ),
                if (litres > 0)
                  Text(
                    '${litres}L',
                    style: const TextStyle(fontSize: 9, color: GrahasthiTheme.blue),
                  )
                else if (noMilk)
                  Text(
                    t('no_milk_short'),
                    style: const TextStyle(fontSize: 9, color: GrahasthiTheme.red),
                    textAlign: TextAlign.center,
                  ),
              ],
            );
          },
          onDayTap: (day) => _showLogMilkDialog(context, milk, typeId, day, defaultQty),
        ),
        const Divider(height: 24),
      ],
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
      ],
    );
  }

  void _showLogMilkDialog(BuildContext context, MilkProvider milk, String typeId, int day, double defaultQty) {
    final existing = milk.getLitresForDay(day, typeId);
    final hasEntry = milk.hasLoggedEntryForDay(day, typeId);
    final isNoMilk = milk.isNoMilkDay(day, typeId);
    final controller = TextEditingController(
      text: hasEntry && !isNoMilk && existing > 0 ? existing.toString() : defaultQty.toString(),
    );
    final t = AppLocalizations.t;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${t('log_milk')} — Day $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: t('enter_litres'),
                suffixText: 'L',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                milk.logNoMilk(day, typeId);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.block, size: 18, color: GrahasthiTheme.red),
              label: Text(t('no_milk_taken')),
              style: OutlinedButton.styleFrom(
                foregroundColor: GrahasthiTheme.red,
                side: const BorderSide(color: GrahasthiTheme.red),
              ),
            ),
          ],
        ),
        actions: [
          if (hasEntry)
            TextButton(
              onPressed: () {
                milk.logMilk(day, typeId, 0);
                Navigator.pop(ctx);
              },
              child: Text(t('delete'), style: const TextStyle(color: GrahasthiTheme.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0;
              if (val > 0) {
                milk.logMilk(day, typeId, val);
                Navigator.pop(ctx);
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void _confirmSetDefaultForMonth(
    BuildContext context,
    MilkProvider milk,
    String typeId,
    String typeName,
    double defaultQty,
  ) {
    final t = AppLocalizations.t;
    final monthName = AppLocalizations.monthName(milk.selectedMonth);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('confirm_set_default_month')),
        content: Text(
          '${t('set_default_month_message').replaceAll('{qty}', '$defaultQty')}\n\n$typeName — $monthName ${milk.selectedYear}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              milk.setDefaultForMonth(typeId, defaultQty);
              Navigator.pop(ctx);
            },
            child: Text(t('set_default_for_month')),
          ),
        ],
      ),
    );
  }

  void _showAddMilkTypeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtyController = TextEditingController(text: '1.0');
    final t = AppLocalizations.t;
    final milk = context.read<MilkProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('add_milk_type')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: t('type_name')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: t('price_per_litre')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: t('default_daily_qty')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0;
              final qty = double.tryParse(qtyController.text) ?? 1;
              if (name.isNotEmpty && price > 0) {
                milk.addMilkType(name: name, pricePerLitre: price, defaultQty: qty);
                Navigator.pop(ctx);
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void _showEditMilkTypeDialog(BuildContext context, Map<String, dynamic> type) {
    final nameController = TextEditingController(text: type['name']);
    final priceController = TextEditingController(text: (type['pricePerLitre'] as num).toString());
    final qtyController = TextEditingController(text: ((type['defaultQty'] as num?) ?? 1).toString());
    final t = AppLocalizations.t;
    final milk = context.read<MilkProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('edit_milk_type')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: t('type_name'))),
            const SizedBox(height: 12),
            TextField(controller: priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: t('price_per_litre'))),
            const SizedBox(height: 12),
            TextField(controller: qtyController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: t('default_daily_qty'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              milk.updateMilkType(type['id'],
                name: nameController.text.trim(),
                pricePerLitre: double.tryParse(priceController.text) ?? 0,
                defaultQty: double.tryParse(qtyController.text) ?? 1,
              );
              Navigator.pop(ctx);
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteType(BuildContext context, String typeId) {
    final t = AppLocalizations.t;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete_milk_type')),
        content: Text(t('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GrahasthiTheme.red),
            onPressed: () {
              context.read<MilkProvider>().deleteMilkType(typeId);
              Navigator.pop(ctx);
            },
            child: Text(t('delete')),
          ),
        ],
      ),
    );
  }
}
