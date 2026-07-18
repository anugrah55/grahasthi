import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../milk/milk_tracker_screen.dart';
import '../maid/maid_list_screen.dart';
import '../grocery/grocery_tracker_screen.dart';
import '../credit/credit_shops_screen.dart';
import '../lpg/lpg_tracker_screen.dart';
import '../electricity/electricity_tracker_screen.dart';
import '../water/water_tracker_screen.dart';
import '../watchman/watchman_list_screen.dart';
import '../vehicle/vehicle_tracker_screen.dart';
import '../emi/emi_tracker_screen.dart';
import '../festival/festival_list_screen.dart';

class TrackersListScreen extends StatelessWidget {
  const TrackersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    context.watch<LanguageProvider>();

    final trackers = [
      {'emoji': '🥛', 'label': t('milk'), 'color': GrahasthiTheme.milkIconBg, 'screen': const MilkTrackerScreen()},
      {'emoji': '🧹', 'label': t('house_help'), 'color': GrahasthiTheme.maidIconBg, 'screen': const MaidListScreen()},
      {'emoji': '🛒', 'label': t('groceries'), 'color': GrahasthiTheme.groceryIconBg, 'screen': const GroceryTrackerScreen()},
      {'emoji': '🏪', 'label': t('shop_credit'), 'color': GrahasthiTheme.creditIconBg, 'screen': const CreditShopsScreen()},
      {'emoji': '🔥', 'label': t('lpg_cylinder'), 'color': GrahasthiTheme.lpgIconBg, 'screen': const LpgTrackerScreen()},
      {'emoji': '⚡', 'label': t('electricity_bill'), 'color': GrahasthiTheme.electricityIconBg, 'screen': const ElectricityTrackerScreen()},
      {'emoji': '💧', 'label': t('water'), 'color': GrahasthiTheme.waterIconBg, 'screen': const WaterTrackerScreen()},
      {'emoji': '💂', 'label': t('security_watchman'), 'color': GrahasthiTheme.watchmanIconBg, 'screen': const WatchmanListScreen()},
      {'emoji': '🚗', 'label': t('vehicle'), 'color': GrahasthiTheme.vehicleIconBg, 'screen': const VehicleTrackerScreen()},
      {'emoji': '📅', 'label': t('emi_bills'), 'color': GrahasthiTheme.emiIconBg, 'screen': const EmiTrackerScreen()},
      {'emoji': '🎉', 'label': t('festival_budget'), 'color': GrahasthiTheme.festivalIconBg, 'screen': const FestivalListScreen()},
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('all_trackers'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  Text(t('app_tagline'), style: const TextStyle(fontSize: 14, color: GrahasthiTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trackers.length,
                itemBuilder: (ctx, i) {
                  final tracker = trackers[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      leading: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: tracker['color'] as Color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(child: Text(tracker['emoji'] as String, style: const TextStyle(fontSize: 26))),
                      ),
                      title: Text(
                        tracker['label'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: GrahasthiTheme.textMuted),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => tracker['screen'] as Widget,
                      )),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
