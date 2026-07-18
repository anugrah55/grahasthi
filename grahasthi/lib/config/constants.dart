class AppConstants {
  // App Info
  static const String appName = 'Grahasthi';
  static const String appNameHindi = 'गृहस्थी';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String milkBox = 'milk_entries';
  static const String milkTypesBox = 'milk_types';
  static const String maidsBox = 'maids';
  static const String maidAttendanceBox = 'maid_attendance';
  static const String maidAdvancesBox = 'maid_advances';
  static const String groceryBox = 'grocery_items';
  static const String shopsBox = 'shops';
  static const String creditBox = 'credit_entries';
  static const String lpgBox = 'lpg_entries';
  static const String electricityBox = 'electricity_bills';
  static const String waterBox = 'water_entries';
  static const String watchmenBox = 'watchmen';
  static const String watchmanAttendanceBox = 'watchman_attendance';
  static const String vehicleFuelBox = 'vehicle_fuel';
  static const String vehicleMaintenanceBox = 'vehicle_maintenance';
  static const String vehicleInfoBox = 'vehicle_info';
  static const String emiBox = 'emi_bills';
  static const String emiPaymentsBox = 'emi_payments';
  static const String festivalsBox = 'festivals';
  static const String festivalExpensesBox = 'festival_expenses';

  // SharedPreferences Keys
  static const String keyLanguage = 'language';
  static const String keyMonthlyBudget = 'monthly_budget';
  static const String keyDarkMode = 'dark_mode';
  static const String keyReminderTime = 'reminder_time';
  static const String keyUserName = 'user_name';
  static const String keyFirstLaunch = 'first_launch';

  // Default Values
  static const double defaultMonthlyBudget = 50000.0;
  static const int defaultLpgReminderDays = 25;
  static const int defaultInsuranceReminderDays = 30;
  static const int defaultEmiReminderDays = 2;

  // Grocery Categories
  static const List<String> groceryCategories = [
    'sabzi',
    'fruits',
    'dairy',
    'grains',
    'spices',
    'cleaning',
    'personal',
    'medicines',
    'snacks',
    'other',
  ];

  // Payment Modes
  static const List<String> paymentModes = [
    'cash',
    'upi',
    'credit',
  ];

  // Fuel Types
  static const List<String> fuelTypes = [
    'petrol',
    'diesel',
    'cng',
  ];

  // Attendance Status
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
  static const String statusHalfDay = 'half';
  static const String statusHoliday = 'holiday';

  // Milk entry sentinel for explicitly logged "no milk taken" days
  static const double noMilkSentinel = -1;
}
