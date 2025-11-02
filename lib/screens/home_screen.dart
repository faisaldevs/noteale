import 'package:flutter/material.dart';
import 'package:noteale_v2/providers/note_provider.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSelectionMode = false;
  final Set<int> _selectedNoteIds = {};

  void _toggleSelectionMode(bool enabled) {
    setState(() {
      _isSelectionMode = enabled;
      if (!enabled) _selectedNoteIds.clear();
    });
  }

  void _toggleNoteSelection(int noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  void _selectAll(List<int> noteIds) {
    setState(() {
      if (_selectedNoteIds.length == noteIds.length) {
        _selectedNoteIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedNoteIds.addAll(noteIds);
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final notesProvider = context.read<NotesProvider>();
    if (_selectedNoteIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Notes'),
        content: Text(
          'Are you sure you want to delete ${_selectedNoteIds.length} selected note(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final id in _selectedNoteIds) {
        await notesProvider.deleteNote(id);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notes deleted')));
        _toggleSelectionMode(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final notes = notesProvider.notes;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedNoteIds.length} selected')
            : Text('DailyNotes ${notes.isEmpty ? "" : "(${notes.length})"}'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _toggleSelectionMode(false),
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  tooltip: 'Select All',
                  onPressed: () => _selectAll(notes.map((n) => n.id!).toList()),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Selected',
                  onPressed: () => _deleteSelected(context),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              ],
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No notes yet'))
          : RefreshIndicator(
              onRefresh: () => notesProvider.loadNotes(),
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final isSelected = _selectedNoteIds.contains(note.id);

                  return GestureDetector(
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        _toggleSelectionMode(true);
                        _toggleNoteSelection(note.id!);
                      }
                    },
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleNoteSelection(note.id!);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditNoteScreen(note: note),
                          ),
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        // NoteCard(note: note),
                        Positioned.fill(child: NoteCard(note: note)),
                        if (_isSelectionMode)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: AnimatedScale(
                              scale: isSelected ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Note'),
            ),
    );
  }
}
