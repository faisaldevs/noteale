import 'package:flutter/material.dart';
import 'package:noteale_v2/providers/note_provider.dart';
import 'package:provider/provider.dart';

/// Drawer widget for filtering notes
class FilterDrawer extends StatelessWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final categories = notesProvider.getCategories();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.filter_list,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // All Notes
          ListTile(
            leading: const Icon(Icons.all_inbox),
            title: const Text('All Notes'),
            selected:
                notesProvider.selectedCategory == null &&
                !notesProvider.showFavoritesOnly,
            onTap: () {
              notesProvider.setCategory(null);
              if (notesProvider.showFavoritesOnly) {
                notesProvider.toggleFavoritesFilter();
              }
              Navigator.pop(context);
            },
          ),
          // Favorites
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            selected: notesProvider.showFavoritesOnly,
            trailing: notesProvider.favoriteNotes > 0
                ? Chip(
                    label: Text('${notesProvider.favoriteNotes}'),
                    visualDensity: VisualDensity.compact,
                  )
                : null,
            onTap: () {
              if (notesProvider.selectedCategory != null) {
                notesProvider.setCategory(null);
              }
              if (!notesProvider.showFavoritesOnly) {
                notesProvider.toggleFavoritesFilter();
              }
              Navigator.pop(context);
            },
          ),
          const Divider(),
          // Categories Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'CATEGORIES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Categories List
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No categories yet',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          else
            ...categories.map((category) {
              final count = notesProvider.notes
                  .where((note) => note.category == category)
                  .length;
              return ListTile(
                leading: const Icon(Icons.label),
                title: Text(category),
                trailing: Chip(
                  label: Text('$count'),
                  visualDensity: VisualDensity.compact,
                ),
                selected: notesProvider.selectedCategory == category,
                onTap: () {
                  if (notesProvider.showFavoritesOnly) {
                    notesProvider.toggleFavoritesFilter();
                  }
                  notesProvider.setCategory(category);
                  Navigator.pop(context);
                },
              );
            }),
        ],
      ),
    );
  }
}
