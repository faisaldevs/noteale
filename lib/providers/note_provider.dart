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

  List<Note> get notes => _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;

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

  /// Apply search filter and sort
  void _applyFiltersAndSort() {
    // Apply search filter
    if (_searchQuery.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            (note.tags?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply sort
    switch (_sortOption) {
      case SortOption.dateModified:
        _filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOption.dateCreated:
        _filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.titleAZ:
        _filteredNotes.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleZA:
        _filteredNotes.sort((a, b) => b.title.compareTo(a.title));
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
