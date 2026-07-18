import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/milk_provider.dart';
import '../../providers/maid_provider.dart';
import '../../providers/grocery_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/lpg_provider.dart';
import '../../providers/electricity_provider.dart';
import '../../providers/water_provider.dart';
import '../../providers/watchman_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/emi_provider.dart';
import '../../providers/festival_provider.dart';
import '../../widgets/budget_summary_card.dart';
import '../../widgets/tracker_card.dart';
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
import '../grocery/add_grocery_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final now = DateTime.now();
    final monthName = AppLocalizations.monthName(now.month);
    final settings = context.watch<SettingsProvider>();

    // Calculate total expenses from all providers
    final milkTotal = context.watch<MilkProvider>().totalAmountThisMonth;
    final maidTotal = context.watch<MaidProvider>().totalMaidExpense;
    final groceryTotal = context.watch<GroceryProvider>().monthlyTotal;
    final creditTotal = context.watch<CreditProvider>().totalOutstanding;
    final lpgTotal = context.watch<LpgProvider>().currentMonthSpend;
    final electricityTotal = context.watch<ElectricityProvider>().currentMonthSpend;
    final waterTotal = context.watch<WaterProvider>().monthlyTotal;
    final watchmanTotal = context.watch<WatchmanProvider>().totalWatchmanExpense;
    final vehicleTotal = context.watch<VehicleProvider>().totalCurrentMonthSpend;
    final emiTotal = context.watch<EmiProvider>().currentMonthPaid;
    final festivalTotal = context.watch<FestivalProvider>().currentMonthSpend;

    final totalExpenses = milkTotal + maidTotal + groceryTotal + lpgTotal +
        electricityTotal + waterTotal + watchmanTotal + vehicleTotal + emiTotal + festivalTotal;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Greeting Header ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.getGreeting()} ${AppLocalizations.getGreetingEmoji()}',
                        style: TextStyle(
                          fontSize: 15,
                          color: GrahasthiTheme.textSecondary,
                        ),
                      ),
                      Text(
                        AppLocalizations.isHindi ? 'गृहस्थी' : 'Grahasthi',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: GrahasthiTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GrahasthiTheme.saffron.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('🏠', style: TextStyle(fontSize: 28)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$monthName ${now.year}',
                style: const TextStyle(
                  fontSize: 14,
                  color: GrahasthiTheme.saffron,
                ),
              ),
              const SizedBox(height: 20),

              // === Budget Summary Card ===
              BudgetSummaryCard(
                totalExpenses: totalExpenses,
                monthlyBudget: settings.monthlyBudget,
              ),
              const SizedBox(height: 24),

              // === This Month header ===
              Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    t('this_month'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: GrahasthiTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // === Tracker Cards Grid ===
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  TrackerCard(
                    emoji: '🥛',
                    label: t('milk'),
                    amount: milkTotal,
                    iconBgColor: GrahasthiTheme.milkIconBg,
                    onTap: () => _navigateTo(context, const MilkTrackerScreen()),
                  ),
                  TrackerCard(
                    emoji: '🧹',
                    label: t('house_help'),
                    amount: maidTotal,
                    iconBgColor: GrahasthiTheme.maidIconBg,
                    onTap: () => _navigateTo(context, const MaidListScreen()),
                  ),
                  TrackerCard(
                    emoji: '🛒',
                    label: t('groceries'),
                    amount: groceryTotal,
                    iconBgColor: GrahasthiTheme.groceryIconBg,
                    onTap: () => _navigateTo(context, const GroceryTrackerScreen()),
                  ),
                  TrackerCard(
                    emoji: '🏪',
                    label: t('shop_credit'),
                    amount: creditTotal,
                    iconBgColor: GrahasthiTheme.creditIconBg,
                    onTap: () => _navigateTo(context, const CreditShopsScreen()),
                  ),
                  TrackerCard(
                    emoji: '🔥',
                    label: t('lpg_cylinder'),
                    amount: lpgTotal,
                    iconBgColor: GrahasthiTheme.lpgIconBg,
                    onTap: () => _navigateTo(context, const LpgTrackerScreen()),
                  ),
                  TrackerCard(
                    emoji: '⚡',
                    label: t('electricity_bill'),
                    amount: electricityTotal,
                    iconBgColor: GrahasthiTheme.electricityIconBg,
                    onTap: () => _navigateTo(context, const ElectricityTrackerScreen()),
                  ),
                  TrackerCard(
                    emoji: '💧',
                    label: t('water'),
                    amount: waterTotal,
                    iconBgColor: GrahasthiTheme.waterIconBg,
                    onTap: () => _navigateTo(context, const WaterTrackerScreen()),
                  ),
                  TrackerCard(
                    emoji: '🚗',
                    label: t('vehicle'),
                    amount: vehicleTotal,
                    iconBgColor: GrahasthiTheme.vehicleIconBg,
                    onTap: () => _navigateTo(context, const VehicleTrackerScreen()),
                  ),
                  TrackerCard(
                    emoji: '📅',
                    label: t('emi_bills'),
                    amount: emiTotal,
                    iconBgColor: GrahasthiTheme.emiIconBg,
                    onTap: () => _navigateTo(context, const EmiTrackerScreen()),
                  ),
                  TrackerCard(
                    emoji: '🎉',
                    label: t('festival_budget'),
                    amount: festivalTotal,
                    iconBgColor: GrahasthiTheme.festivalIconBg,
                    onTap: () => _navigateTo(context, const FestivalListScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateTo(context, const AddGroceryScreen()),
        backgroundColor: GrahasthiTheme.saffron,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
