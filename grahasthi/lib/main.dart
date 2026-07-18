import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/language_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/milk_provider.dart';
import 'providers/maid_provider.dart';
import 'providers/grocery_provider.dart';
import 'providers/credit_provider.dart';
import 'providers/lpg_provider.dart';
import 'providers/electricity_provider.dart';
import 'providers/water_provider.dart';
import 'providers/watchman_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/emi_provider.dart';
import 'providers/festival_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1E1E1E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize storage
  await StorageService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()..init()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => MilkProvider()..init()),
        ChangeNotifierProvider(create: (_) => MaidProvider()..init()),
        ChangeNotifierProvider(create: (_) => GroceryProvider()..init()),
        ChangeNotifierProvider(create: (_) => CreditProvider()..init()),
        ChangeNotifierProvider(create: (_) => LpgProvider()..init()),
        ChangeNotifierProvider(create: (_) => ElectricityProvider()..init()),
        ChangeNotifierProvider(create: (_) => WaterProvider()..init()),
        ChangeNotifierProvider(create: (_) => WatchmanProvider()..init()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()..init()),
        ChangeNotifierProvider(create: (_) => EmiProvider()..init()),
        ChangeNotifierProvider(create: (_) => FestivalProvider()..init()),
      ],
      child: const GrahasthiApp(),
    ),
  );
}
