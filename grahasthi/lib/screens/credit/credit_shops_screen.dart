import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/credit_provider.dart';
import 'shop_ledger_screen.dart';

class CreditShopsScreen extends StatelessWidget {
  const CreditShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final credit = context.watch<CreditProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t('credit_tracker'))),
      body: credit.shops.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏪', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(t('no_shops'), style: const TextStyle(fontSize: 16, color: GrahasthiTheme.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(onPressed: () => _showAddShopDialog(context), icon: const Icon(Icons.add), label: Text(t('add_shop'))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: credit.shops.length,
              itemBuilder: (ctx, i) {
                final shop = credit.shops[i];
                final balance = credit.getOutstandingBalance(shop['id']);
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: GrahasthiTheme.creditIconBg, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('🏪', style: TextStyle(fontSize: 24))),
                    ),
                    title: Text(shop['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(t('outstanding'), style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
                    trailing: Text(
                      AppLocalizations.formatCurrency(balance),
                      style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold,
                        color: balance > 0 ? GrahasthiTheme.red : GrahasthiTheme.green,
                      ),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ShopLedgerScreen(shopId: shop['id']),
                    )),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddShopDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddShopDialog(BuildContext context) {
    final controller = TextEditingController();
    final t = AppLocalizations.t;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('add_shop')),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: t('shop_name'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<CreditProvider>().addShop(controller.text.trim());
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
