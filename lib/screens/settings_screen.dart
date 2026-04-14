// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  void _toggleNotifications(bool value) {
    setState(() => _notifications = value);
    // TODO: enregistrer la préférence (ex: SharedPreferences) et gérer les push notifications
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres', style: textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: colorScheme.background,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mode sombre & notifications
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text('Mode sombre', style: textTheme.bodyMedium),
                  secondary: Icon(Icons.dark_mode, color: colorScheme.primary),
                  value: themeProvider.isDark,
                  onChanged: (v) => context.read<ThemeProvider>().toggleDarkMode(v),
                ),
                Divider(thickness: 1, height: 0),
                SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text('Notifications', style: textTheme.bodyMedium),
                  secondary: Icon(Icons.notifications, color: colorScheme.primary),
                  value: _notifications,
                  onChanged: _toggleNotifications,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Choix de la langue
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.language, color: colorScheme.primary),
              title: Text('Langue', style: textTheme.bodyMedium),
              subtitle: Text('Français', style: textTheme.bodySmall),
              trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.6)),
              onTap: () {
                // TODO: afficher un BottomSheet ou Navigator vers la sélection de langue
              },
            ),
          ),
          const SizedBox(height: 24),

          // À propos
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.info_outline, color: colorScheme.primary),
              title: Text('À propos', style: textTheme.bodyMedium),
              trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.6)),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SmartRoute',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(Icons.map, size: 48, color: colorScheme.primary),
                  children: [Text('Application de détection et de signalement de nids-de-poule.')],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Se déconnecter
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text('Se déconnecter', style: textTheme.bodyMedium!.copyWith(color: colorScheme.error)),
              onTap: _signOut,
            ),
          ),
        ],
      ),
    );
  }
}
