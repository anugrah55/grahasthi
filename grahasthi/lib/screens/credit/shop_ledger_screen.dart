import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/credit_provider.dart';
import '../../providers/language_provider.dart';

class ShopLedgerScreen extends StatelessWidget {
  final String shopId;
  const ShopLedgerScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final credit = context.watch<CreditProvider>();
    final lang = context.watch<LanguageProvider>().language;
    final shop = credit.shops.firstWhere((s) => s['id'] == shopId, orElse: () => {});
    if (shop.isEmpty) return Scaffold(appBar: AppBar());

    final entries = credit.getEntriesForShop(shopId);
    final balance = credit.getOutstandingBalance(shopId);

    return Scaffold(
      appBar: AppBar(
        title: Text(shop['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: GrahasthiTheme.saffron),
            onPressed: () => Share.share(credit.getShareTextForShop(shopId, lang)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GrahasthiTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GrahasthiTheme.cardBorder),
            ),
            child: Column(
              children: [
                Text(t('balance'), style: const TextStyle(fontSize: 14, color: GrahasthiTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.formatCurrency(balance),
                  style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold,
                    color: balance > 0 ? GrahasthiTheme.red : GrahasthiTheme.green,
                  ),
                ),
                if (balance <= 0) Text(t('settled'), style: const TextStyle(color: GrahasthiTheme.green)),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddCreditDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(t('add_credit'), style: const TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddPaymentDialog(context),
                    icon: const Icon(Icons.payment, size: 18),
                    label: Text(t('add_payment'), style: const TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Ledger list
          Expanded(
            child: entries.isEmpty
                ? Center(child: Text(t('no_entries'), style: const TextStyle(color: GrahasthiTheme.textMuted)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length,
                    itemBuilder: (ctx, i) {
                      final entry = entries[i];
                      final isPayment = entry['isPayment'] == true;
                      return Dismissible(
                        key: Key(entry['key']),
                        direction: DismissDirection.endToStart,
                        background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: GrahasthiTheme.red)),
                        onDismissed: (_) => credit.deleteEntry(entry['key']),
                        child: Card(
                          child: ListTile(
                            leading: Icon(
                              isPayment ? Icons.check_circle : Icons.receipt_long,
                              color: isPayment ? GrahasthiTheme.green : GrahasthiTheme.red,
                            ),
                            title: Text(entry['item'] ?? ''),
                            subtitle: Text(entry['date'] ?? '', style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
                            trailing: Text(
                              '${isPayment ? '-' : '+'}${AppLocalizations.formatCurrency((entry['amount'] as num).toDouble())}',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600,
                                color: isPayment ? GrahasthiTheme.green : GrahasthiTheme.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddCreditDialog(BuildContext context) {
    final itemController = TextEditingController();
    final amountController = TextEditingController();
    final t = AppLocalizations.t;
    final dateStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('add_credit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: itemController, decoration: InputDecoration(labelText: t('item'))),
            const SizedBox(height: 12),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('amount'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (itemController.text.trim().isNotEmpty && amount > 0) {
                context.read<CreditProvider>().addCreditEntry(shopId, item: itemController.text.trim(), amount: amount, date: dateStr);
                Navigator.pop(ctx);
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    final amountController = TextEditingController();
    final t = AppLocalizations.t;
    final dateStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('add_payment')),
        content: TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('amount'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                context.read<CreditProvider>().addPayment(shopId, amount: amount, date: dateStr);
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
