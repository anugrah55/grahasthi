import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/language_provider.dart';
import 'screens/language_selection_screen.dart';
import 'screens/main_shell.dart';

class GrahasthiApp extends StatelessWidget {
  const GrahasthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, _) {
        return MaterialApp(
          title: 'Grahasthi - गृहस्थी',
          debugShowCheckedModeBanner: false,
          theme: GrahasthiTheme.darkTheme,
          home: FutureBuilder<bool>(
            future: langProvider.hasSelectedLanguage(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: GrahasthiTheme.saffron,
                    ),
                  ),
                );
              }

              if (snapshot.data == true) {
                return const MainShell();
              } else {
                return const LanguageSelectionScreen();
              }
            },
          ),
        );
      },
    );
  }
}
