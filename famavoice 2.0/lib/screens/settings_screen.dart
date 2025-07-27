import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:famavoice/services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'), // This will be dynamic later
            onTap: () {
              // TODO: Implement language selection
            },
          ),
          const Divider(),
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Theme'),
                subtitle: Text(themeService.themeMode == ThemeMode.light ? 'Light' : 'Dark'),
                onTap: () {
                  themeService.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}