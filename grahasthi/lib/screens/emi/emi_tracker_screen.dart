import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/emi_provider.dart';

class EmiTrackerScreen extends StatelessWidget {
  const EmiTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final emi = context.watch<EmiProvider>();
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(t('emi_tracker'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Fixed obligations summary
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: GrahasthiTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: GrahasthiTheme.cardBorder)),
            child: Column(children: [
              Text(t('fixed_obligations'), style: const TextStyle(fontSize: 14, color: GrahasthiTheme.textSecondary)),
              const SizedBox(height: 4),
              Text(AppLocalizations.formatCurrency(emi.totalMonthlyObligations), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _statusChip('${emi.paidCount} ${t('paid')}', GrahasthiTheme.green),
                const SizedBox(width: 12),
                _statusChip('${emi.unpaidCount} ${t('unpaid')}', GrahasthiTheme.red),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // EMI list
          ...emi.emis.map((item) {
            final paid = emi.isPaid(item['id'], now.year, now.month);
            final dueDay = (item['dueDate'] as num).toInt();
            final isOverdue = !paid && dueDay < now.day;

            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: paid ? GrahasthiTheme.green.withOpacity(0.15) : isOverdue ? GrahasthiTheme.red.withOpacity(0.15) : GrahasthiTheme.emiIconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Icon(paid ? Icons.check_circle : Icons.receipt_long, color: paid ? GrahasthiTheme.green : isOverdue ? GrahasthiTheme.red : GrahasthiTheme.saffron, size: 24)),
                ),
                title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${t('due_date')}: $dueDay • ${item['isAutoDebit'] == true ? t('auto_debit') : t('manual')}',
                  style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted),
                ),
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(AppLocalizations.formatCurrency((item['amount'] as num).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: GrahasthiTheme.saffron)),
                  GestureDetector(
                    onTap: () => emi.markPaid(item['id'], now.year, now.month, !paid),
                    child: Text(paid ? t('paid') : t('mark_paid'), style: TextStyle(fontSize: 11, color: paid ? GrahasthiTheme.green : GrahasthiTheme.yellow)),
                  ),
                ]),
                onLongPress: () => _showEditDialog(context, item),
              ),
            );
          }),

          if (emi.emis.isEmpty)
            Padding(padding: const EdgeInsets.only(top: 60), child: Column(children: [
              const Text('📅', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(t('no_emi'), style: const TextStyle(color: GrahasthiTheme.textMuted)),
            ])),
        ]),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context), child: const Icon(Icons.add)),
    );
  }

  Widget _statusChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
  );

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dueDateController = TextEditingController();
    bool isAutoDebit = false;
    final t = AppLocalizations.t;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(t('add_emi')),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: InputDecoration(labelText: t('bill_name'))),
          const SizedBox(height: 12),
          TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('amount'))),
          const SizedBox(height: 12),
          TextField(controller: dueDateController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('due_date'), hintText: '1-31')),
          const SizedBox(height: 12),
          SwitchListTile(title: Text(t('auto_debit')), value: isAutoDebit, onChanged: (val) => setState(() => isAutoDebit = val), activeColor: GrahasthiTheme.saffron, contentPadding: EdgeInsets.zero),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(onPressed: () {
            final name = nameController.text.trim();
            final amount = double.tryParse(amountController.text) ?? 0;
            final dueDate = int.tryParse(dueDateController.text) ?? 1;
            if (name.isNotEmpty && amount > 0) {
              context.read<EmiProvider>().addEmi(name: name, amount: amount, dueDate: dueDate.clamp(1, 31), isAutoDebit: isAutoDebit);
              Navigator.pop(ctx);
            }
          }, child: Text(t('save'))),
        ],
      ),
    ));
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> item) {
    final t = AppLocalizations.t;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item['name'] ?? ''),
      content: Text(t('confirm_delete')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: GrahasthiTheme.red),
          onPressed: () { context.read<EmiProvider>().deleteEmi(item['id']); Navigator.pop(ctx); },
          child: Text(t('delete')),
        ),
      ],
    ));
  }
}
