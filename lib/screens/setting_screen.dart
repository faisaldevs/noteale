import 'package:flutter/material.dart';
import 'package:noteale_v2/core/app_info_v2.dart';
import 'package:noteale_v2/providers/note_provider.dart';
import 'package:noteale_v2/providers/setting_provider.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark theme'),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return SwitchListTile(
                title: const Text('Grid View'),
                subtitle: const Text('Display notes in grid layout'),
                value: settings.gridView,
                onChanged: (_) => settings.toggleGridView(),
                secondary: const Icon(Icons.grid_view),
              );
            },
          ),

          const Divider(),

          // Editor Section
          _buildSectionHeader(context, 'Editor'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return SwitchListTile(
                title: const Text('Auto Save'),
                subtitle: Text(
                  'Save notes every ${settings.autoSaveInterval} seconds',
                ),
                value: settings.autoSave,
                onChanged: (value) => settings.setAutoSave(value),
                secondary: const Icon(Icons.save),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return SwitchListTile(
                title: const Text('Show Word Count'),
                subtitle: const Text('Display word count in notes'),
                value: settings.showWordCount,
                onChanged: (_) => settings.toggleWordCount(),
                secondary: const Icon(Icons.text_fields),
              );
            },
          ),

          const Divider(),

          // Behavior Section
          _buildSectionHeader(context, 'Behavior'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return SwitchListTile(
                title: const Text('Confirm Before Delete'),
                subtitle: const Text('Show confirmation dialog'),
                value: settings.confirmDelete,
                onChanged: (_) => settings.toggleConfirmDelete(),
                secondary: const Icon(Icons.warning),
              );
            },
          ),

          const Divider(),

          // Statistics Section
          _buildSectionHeader(context, 'Statistics'),
          Consumer<NotesProvider>(
            builder: (context, notesProvider, _) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.note),
                    title: const Text('Total Notes'),
                    trailing: Text(
                      '${notesProvider.totalNotes}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('Favorite Notes'),
                    trailing: Text(
                      '${notesProvider.favoriteNotes}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.push_pin),
                    title: const Text('Pinned Notes'),
                    trailing: Text(
                      '${notesProvider.pinnedNotes}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Categories'),
                    trailing: Text(
                      '${notesProvider.getCategories().length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              );
            },
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            trailing: FutureBuilder(
              future: VersionService().init(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(VersionService().version);
                } else {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Developer'),
            subtitle: const Text('Built with Flutter'),
          ),

          const SizedBox(height: 16),

          // Reset Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text(
                      'Are you sure you want to reset all settings to default?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await context.read<SettingsProvider>().resetSettings();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings reset to default'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.restore),
              label: const Text('Reset All Settings'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
