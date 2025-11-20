import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noteale_v2/core/version_checker_v2.dart';
import 'package:noteale_v2/providers/note_provider.dart';
import 'package:noteale_v2/providers/setting_provider.dart';
import 'package:noteale_v2/screens/filter_drawer.dart';
import 'package:noteale_v2/screens/setting_screen.dart';
import 'package:noteale_v2/widgets/note_grid_item.dart';
import 'package:provider/provider.dart';

import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';

/// Home screen displaying list of all notes
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        // Mock for testing
        PlayStoreUpdateChecker.showMockUpdateDialog(context);
      } else {
        PlayStoreUpdateChecker.checkForUpdate(context);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  context.read<NotesProvider>().searchNotes(value);
                },
              )
            : const Text('DailyNotes'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  context.read<NotesProvider>().clearSearch();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          // Sort menu
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (option) {
              context.read<NotesProvider>().setSortOption(option);
            },
            itemBuilder: (context) {
              final currentSort = context.read<NotesProvider>().sortOption;
              return SortOption.values
                  .map(
                    (option) => PopupMenuItem(
                      value: option,
                      child: Row(
                        children: [
                          if (currentSort == option)
                            const Icon(Icons.check, size: 20),
                          if (currentSort == option) const SizedBox(width: 8),
                          Text(option.displayName),
                        ],
                      ),
                    ),
                  )
                  .toList();
            },
          ),
          // View mode toggle
          IconButton(
            icon: Icon(settings.gridView ? Icons.view_list : Icons.grid_view),
            tooltip: settings.gridView ? 'List View' : 'Grid View',
            onPressed: () => settings.toggleGridView(),
          ),
          // More menu
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
      drawer: const FilterDrawer(),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          if (notesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notesProvider.notes.isEmpty) {
            return EmptyState(
              isSearching: _isSearching,
              onClearSearch: () {
                setState(() {
                  _searchController.clear();
                  notesProvider.clearSearch();
                  _isSearching = false;
                });
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => notesProvider.loadNotes(),
            child: settings.gridView
                ? _buildGridView(notesProvider)
                : _buildListView(notesProvider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }

  Widget _buildListView(NotesProvider notesProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notesProvider.notes.length,
      itemBuilder: (context, index) {
        final note = notesProvider.notes[index];
        return Dismissible(
          key: Key(note.id.toString()),
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            final settings = context.read<SettingsProvider>();
            if (!settings.confirmDelete) return true;

            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Note'),
                content: const Text(
                  'Are you sure you want to delete this note?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            notesProvider.deleteNote(note.id!);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Note deleted')));
          },
          child: NoteCard(note: note),
        );
      },
    );
  }

  Widget _buildGridView(NotesProvider notesProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: notesProvider.notes.length,
      itemBuilder: (context, index) {
        final note = notesProvider.notes[index];
        return NoteGridItem(note: note);
      },
    );
  }
}
