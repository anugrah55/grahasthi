import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
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

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final now = DateTime.now();
    final monthName = AppLocalizations.monthName(now.month);
    context.watch<LanguageProvider>();

    // Gather totals from all providers
    final categories = _getCategoryTotals(context);
    final monthlyTotal = categories.values.fold(0.0, (sum, v) => sum + v);

    // Find biggest expense
    String biggestCategory = '';
    double biggestAmount = 0;
    categories.forEach((key, value) {
      if (value > biggestAmount) {
        biggestAmount = value;
        biggestCategory = key;
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('reports_title'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text('$monthName ${now.year}', style: const TextStyle(fontSize: 14, color: GrahasthiTheme.textSecondary)),
              const SizedBox(height: 20),

              // Monthly overview + YTD
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: GrahasthiTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: GrahasthiTheme.cardBorder)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t('monthly_overview'), style: const TextStyle(fontSize: 13, color: GrahasthiTheme.textSecondary)),
                    Text(AppLocalizations.formatCurrency(monthlyTotal), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                    Text('$monthName ${now.year}', style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(t('year_to_date'), style: const TextStyle(fontSize: 13, color: GrahasthiTheme.textSecondary)),
                    Text(AppLocalizations.formatCurrency(monthlyTotal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: GrahasthiTheme.textPrimary)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),

              // Biggest expense callout
              if (biggestCategory.isNotEmpty)
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GrahasthiTheme.saffron.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GrahasthiTheme.saffron.withOpacity(0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('🏆 ${t('biggest_expense')}', style: const TextStyle(fontSize: 13, color: GrahasthiTheme.saffron)),
                    const SizedBox(height: 4),
                    Text(biggestCategory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(AppLocalizations.formatCurrency(biggestAmount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: GrahasthiTheme.saffron)),
                  ]),
                ),
              const SizedBox(height: 20),

              // Bar chart - current month breakdown
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: GrahasthiTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: GrahasthiTheme.cardBorder)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('category_wise'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (categories.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (biggestAmount * 1.2).ceilToDouble(),
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final keys = categories.keys.toList();
                                  if (value.toInt() < keys.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _shortLabel(keys[value.toInt()]),
                                        style: const TextStyle(fontSize: 9, color: GrahasthiTheme.textMuted),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                getTitlesWidget: (value, meta) {
                                  return Text('₹${(value / 1000).toStringAsFixed(0)}k',
                                    style: const TextStyle(fontSize: 10, color: GrahasthiTheme.textMuted));
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: true, drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => const FlLine(color: GrahasthiTheme.cardBorder, strokeWidth: 0.5)),
                          borderData: FlBorderData(show: false),
                          barGroups: categories.entries.toList().asMap().entries.map((mapEntry) {
                            return BarChartGroupData(
                              x: mapEntry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: mapEntry.value.value,
                                  color: GrahasthiTheme.saffron,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(t('no_data'), style: const TextStyle(color: GrahasthiTheme.textMuted)))),
                ]),
              ),
              const SizedBox(height: 16),

              // Category-wise list breakdown
              ...categories.entries.where((e) => e.value > 0).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: GrahasthiTheme.saffron, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    Text(e.key, style: const TextStyle(fontSize: 14, color: GrahasthiTheme.textSecondary)),
                  ]),
                  Text(AppLocalizations.formatCurrency(e.value), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ]),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _getCategoryTotals(BuildContext context) {
    final t = AppLocalizations.t;
    final map = <String, double>{};

    final milk = context.watch<MilkProvider>().totalAmountThisMonth;
    if (milk > 0) map[t('milk')] = milk;

    final maid = context.watch<MaidProvider>().totalMaidExpense;
    if (maid > 0) map[t('house_help')] = maid;

    final grocery = context.watch<GroceryProvider>().monthlyTotal;
    if (grocery > 0) map[t('groceries')] = grocery;

    final lpg = context.watch<LpgProvider>().currentMonthSpend;
    if (lpg > 0) map[t('lpg_cylinder')] = lpg;

    final electricity = context.watch<ElectricityProvider>().currentMonthSpend;
    if (electricity > 0) map[t('electricity_bill')] = electricity;

    final water = context.watch<WaterProvider>().monthlyTotal;
    if (water > 0) map[t('water')] = water;

    final watchman = context.watch<WatchmanProvider>().totalWatchmanExpense;
    if (watchman > 0) map[t('security_watchman')] = watchman;

    final vehicle = context.watch<VehicleProvider>().totalCurrentMonthSpend;
    if (vehicle > 0) map[t('vehicle')] = vehicle;

    final emi = context.watch<EmiProvider>().currentMonthPaid;
    if (emi > 0) map[t('emi_bills')] = emi;

    final festival = context.watch<FestivalProvider>().currentMonthSpend;
    if (festival > 0) map[t('festival_budget')] = festival;

    return map;
  }

  String _shortLabel(String label) {
    if (label.length <= 6) return label;
    return '${label.substring(0, 5)}…';
  }
}
