import 'package:flutter/material.dart';
import 'package:noteale_v2/model/note.dart';

import '../db/database_helper.dart';

/// Provider class for managing notes state
class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dateModified;
  String? _selectedCategory;
  bool _showFavoritesOnly = false;

  List<Note> get notes => _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  String? get selectedCategory => _selectedCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;

  // Statistics
  int get totalNotes => _notes.length;
  int get pinnedNotes => _notes.where((n) => n.isPinned).length;
  int get favoriteNotes => _notes.where((n) => n.isFavorite).length;

  NotesProvider() {
    loadNotes();
  }

  /// Load all notes from database
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await DatabaseHelper.instance.readAllNotes();
      _applyFiltersAndSort();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new note
  Future<void> addNote(Note note) async {
    try {
      final newNote = await DatabaseHelper.instance.createNote(note);
      _notes.insert(0, newNote);
      _applyFiltersAndSort();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note: $e');
      rethrow;
    }
  }

  /// Update an existing note
  Future<void> updateNote(Note note) async {
    try {
      await DatabaseHelper.instance.updateNote(note);
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        _applyFiltersAndSort();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
      rethrow;
    }
  }

  /// Delete a note
  Future<void> deleteNote(int id) async {
    try {
      await DatabaseHelper.instance.deleteNote(id);
      _notes.removeWhere((note) => note.id == id);
      _applyFiltersAndSort();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }

  /// Toggle pin status
  Future<void> togglePin(Note note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updatedNote);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(Note note) async {
    final updatedNote = note.copyWith(isFavorite: !note.isFavorite);
    await updateNote(updatedNote);
  }

  /// Search notes by query
  void searchNotes(String query) {
    _searchQuery = query.trim();
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Change sort option
  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Filter by category
  void setCategory(String? category) {
    _selectedCategory = category;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Toggle favorites filter
  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Get all unique categories
  List<String> getCategories() {
    final categories = <String>{};
    for (var note in _notes) {
      if (note.category != null && note.category!.isNotEmpty) {
        categories.add(note.category!);
      }
    }
    return categories.toList()..sort();
  }

  /// Apply search filter and sort
  void _applyFiltersAndSort() {
    _filteredNotes = List.from(_notes);

    // Apply favorites filter
    if (_showFavoritesOnly) {
      _filteredNotes = _filteredNotes.where((note) => note.isFavorite).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      _filteredNotes = _filteredNotes
          .where((note) => note.category == _selectedCategory)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _filteredNotes = _filteredNotes.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            (note.tags?.toLowerCase().contains(query) ?? false) ||
            (note.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply sort
    switch (_sortOption) {
      case SortOption.dateModified:
        _filteredNotes.sort((a, b) {
          // Pinned notes always on top
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
      case SortOption.dateCreated:
        _filteredNotes.sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case SortOption.titleAZ:
        _filteredNotes.sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
      case SortOption.titleZA:
        _filteredNotes.sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        });
        break;
    }
  }

  /// Get a single note by id
  Note? getNoteById(int id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    return await DatabaseHelper.instance.getStatistics();
  }

  /// Duplicate a note
  Future<void> duplicateNote(Note note) async {
    final duplicated = note.copyWith(
      id: null,
      title: '${note.title} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
    );
    await addNote(duplicated);
  }
}

/// Sort options enum
enum SortOption { dateModified, dateCreated, titleAZ, titleZA }

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.dateModified:
        return 'Date Modified';
      case SortOption.dateCreated:
        return 'Date Created';
      case SortOption.titleAZ:
        return 'Title (A-Z)';
      case SortOption.titleZA:
        return 'Title (Z-A)';
    }
  }
}
