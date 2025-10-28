import 'package:flutter/material.dart';
import 'package:noteale_v2/providers/note_provider.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) {
              context.read<NotesProvider>().setSortOption(option);
            },
            itemBuilder: (context) => SortOption.values.map((option) {
              final currentSort = context.read<NotesProvider>().sortOption;
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    if (currentSort == option)
                      const Icon(Icons.check, size: 20),
                    if (currentSort == option) const SizedBox(width: 8),
                    Text(option.displayName),
                  ],
                ),
              );
            }).toList(),
          ),

          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notesProvider.notes.length,
              itemBuilder: (context, index) {
                final note = notesProvider.notes[index];
                return Dismissible(
                  key: Key(note.id.toString()),
                  background: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note deleted')),
                    );
                  },
                  child: NoteCard(note: note),
                );
              },
            ),
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
}
