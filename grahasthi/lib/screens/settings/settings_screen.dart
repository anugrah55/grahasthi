import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../providers/settings_provider.dart';
import '../language_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;
    final lang = context.watch<LanguageProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('settings_title'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // === Language ===
              _sectionHeader('🌐', t('language')),
              Card(
                child: ListTile(
                  title: Text(t('language')),
                  subtitle: Text(lang.isHindi ? 'हिंदी' : 'English', style: const TextStyle(color: GrahasthiTheme.saffron)),
                  trailing: const Icon(Icons.chevron_right, color: GrahasthiTheme.textMuted),
                  onTap: () => _showLanguageDialog(context, lang),
                ),
              ),
              const SizedBox(height: 16),

              // === Budget ===
              _sectionHeader('💰', t('budget_settings')),
              Card(
                child: ListTile(
                  title: Text(t('monthly_budget')),
                  subtitle: Text(AppLocalizations.formatCurrency(settings.monthlyBudget), style: const TextStyle(color: GrahasthiTheme.saffron)),
                  trailing: const Icon(Icons.edit, color: GrahasthiTheme.textMuted, size: 20),
                  onTap: () => _showBudgetDialog(context, settings),
                ),
              ),
              const SizedBox(height: 16),

              // === Reminders ===
              _sectionHeader('🔔', t('reminders')),
              Card(
                child: ListTile(
                  title: Text(t('reminder_time')),
                  subtitle: Text(
                    '${settings.reminderHour.toString().padLeft(2, '0')}:${settings.reminderMinute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: GrahasthiTheme.saffron),
                  ),
                  trailing: const Icon(Icons.access_time, color: GrahasthiTheme.textMuted, size: 20),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: settings.reminderHour, minute: settings.reminderMinute),
                       builder: (ctx, child) => Theme(
                        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: GrahasthiTheme.saffron)),
                        child: child!,
                      ),
                    );
                    if (time != null) {
                      settings.setReminderTime(time.hour, time.minute);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // === Backup ===
              _sectionHeader('☁️', t('backup')),
              Card(
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_upload, color: GrahasthiTheme.saffron),
                    title: Text(t('backup')),
                    onTap: () => _showMessage(context, AppLocalizations.isHindi ? 'Google Drive बैकअप जल्द आ रहा है' : 'Google Drive backup coming soon'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_download, color: GrahasthiTheme.saffron),
                    title: Text(t('restore')),
                    onTap: () => _showMessage(context, AppLocalizations.isHindi ? 'रिस्टोर जल्द आ रहा है' : 'Restore coming soon'),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // === About ===
              _sectionHeader('ℹ️', t('about')),
              Card(
                child: Column(children: [
                  ListTile(
                    title: const Text('Grahasthi (गृहस्थी)'),
                    subtitle: Text(
                      AppLocalizations.isHindi
                          ? 'भारतीय परिवारों के लिए घरेलू खर्च और स्टाफ प्रबंधन ऐप'
                          : 'Household expense & staff management for Indian families',
                      style: const TextStyle(fontSize: 12, color: GrahasthiTheme.textMuted),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(t('version')),
                    trailing: const Text(AppConstants.appVersion, style: TextStyle(color: GrahasthiTheme.textSecondary)),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Made with love
              Center(
                child: Text(
                  AppLocalizations.isHindi ? '❤️ भारत में बनाया गया' : '❤️ Made in India',
                  style: const TextStyle(fontSize: 13, color: GrahasthiTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: GrahasthiTheme.textSecondary)),
      ]),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider lang) {
    final t = AppLocalizations.t;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('language')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: const Text('English'),
            trailing: !lang.isHindi ? const Icon(Icons.check, color: GrahasthiTheme.saffron) : null,
            onTap: () { lang.setLanguage('en'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('हिंदी'),
            trailing: lang.isHindi ? const Icon(Icons.check, color: GrahasthiTheme.saffron) : null,
            onTap: () { lang.setLanguage('hi'); Navigator.pop(ctx); },
          ),
        ]),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.monthlyBudget.toInt().toString());
    final t = AppLocalizations.t;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('set_budget')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: t('enter_budget'),
            prefixText: '₹ ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(controller.text) ?? 0;
              if (budget > 0) {
                settings.setMonthlyBudget(budget);
                Navigator.pop(ctx);
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
