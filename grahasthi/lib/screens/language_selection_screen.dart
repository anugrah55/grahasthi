import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/language_provider.dart';
import 'main_shell.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon / logo area
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: GrahasthiTheme.saffron.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    '🏠',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // App name
              const Text(
                'Grahasthi',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: GrahasthiTheme.textPrimary,
                ),
              ),
              const Text(
                'गृहस्थी',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: GrahasthiTheme.saffron,
                ),
              ),
              const SizedBox(height: 48),

              // Choose language text
              const Text(
                'Choose Your Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: GrahasthiTheme.textPrimary,
                ),
              ),
              const Text(
                'अपनी भाषा चुनें',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: GrahasthiTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can change this anytime from Settings',
                style: TextStyle(
                  fontSize: 13,
                  color: GrahasthiTheme.textMuted,
                ),
              ),
              const SizedBox(height: 36),

              // English button
              _LanguageButton(
                label: 'English',
                subtitle: 'Continue in English',
                icon: '🇬🇧',
                onTap: () => _selectLanguage(context, 'en'),
              ),
              const SizedBox(height: 16),

              // Hindi button
              _LanguageButton(
                label: 'हिंदी',
                subtitle: 'हिंदी में जारी रखें',
                icon: '🇮🇳',
                onTap: () => _selectLanguage(context, 'hi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectLanguage(BuildContext context, String lang) async {
    final langProvider = context.read<LanguageProvider>();
    await langProvider.setLanguage(lang);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final String icon;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: GrahasthiTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GrahasthiTheme.cardBorder, width: 1),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: GrahasthiTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: GrahasthiTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: GrahasthiTheme.saffron,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
