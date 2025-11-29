// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:noteale_v2/model/note.dart';
// import 'package:noteale_v2/providers/note_provider.dart';
// import 'package:noteale_v2/providers/setting_provider.dart';
// import 'package:provider/provider.dart';

// /// Screen for adding a new note or editing an existing one
// class AddEditNoteScreen extends StatefulWidget {
//   final Note? note;

//   const AddEditNoteScreen({super.key, this.note});

//   @override
//   State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
// }

// class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _contentController;
//   late TextEditingController _tagsController;
//   late TextEditingController _categoryController;
//   bool _isSaving = false;
//   Timer? _autoSaveTimer;
//   String? _selectedColor;

//   final List<String> _colorOptions = [
//     'red',
//     'blue',
//     'green',
//     'yellow',
//     'purple',
//     'orange',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with existing note data if editing
//     _titleController = TextEditingController(text: widget.note?.title ?? '');
//     _contentController = TextEditingController(
//       text: widget.note?.content ?? '',
//     );
//     _tagsController = TextEditingController(text: widget.note?.tags ?? '');
//     _categoryController = TextEditingController(
//       text: widget.note?.category ?? '',
//     );
//     _selectedColor = widget.note?.color;

//     // Set up auto-save
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final settings = context.read<SettingsProvider>();
//       if (settings.autoSave) {
//         _startAutoSave(settings.autoSaveInterval);
//       }
//     });

//     // Listen to content changes for word count
//     _contentController.addListener(() {
//       setState(() {});
//     });
//   }

//   void _startAutoSave(int seconds) {
//     _autoSaveTimer?.cancel();
//     _autoSaveTimer = Timer.periodic(Duration(seconds: seconds), (_) {
//       if (_titleController.text.trim().isNotEmpty) {
//         _saveNote(showSnackbar: false);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _autoSaveTimer?.cancel();
//     _titleController.dispose();
//     _contentController.dispose();
//     _tagsController.dispose();
//     _categoryController.dispose();
//     super.dispose();
//   }

//   /// Save note (create new or update existing)
//   Future<void> _saveNote({bool showSnackbar = true}) async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() => _isSaving = true);

//     try {
//       final now = DateTime.now();
//       final note = Note(
//         id: widget.note?.id,
//         title: _titleController.text.trim(),
//         content: _contentController.text.trim(),
//         tags: _tagsController.text.trim().isNotEmpty
//             ? _tagsController.text.trim()
//             : null,
//         category: _categoryController.text.trim().isNotEmpty
//             ? _categoryController.text.trim()
//             : null,
//         color: _selectedColor,
//         createdAt: widget.note?.createdAt ?? now,
//         updatedAt: now,
//         isPinned: widget.note?.isPinned ?? false,
//         isFavorite: widget.note?.isFavorite ?? false,
//       );

//       final notesProvider = context.read<NotesProvider>();

//       if (widget.note == null) {
//         // Create new note
//         await notesProvider.addNote(note);
//         if (mounted && showSnackbar) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text('Note created')));
//           Navigator.pop(context);
//         }
//       } else {
//         // Update existing note
//         await notesProvider.updateNote(note);
//         if (mounted && showSnackbar) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text('Note updated')));
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isSaving = false);
//       }
//     }
//   }

//   int get _wordCount {
//     final text = _contentController.text.trim();
//     if (text.isEmpty) return 0;
//     return text.split(RegExp(r'\s+')).length;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.note != null;
//     final settings = context.watch<SettingsProvider>();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditing ? 'Edit Note' : 'New Note'),
//         actions: [
//           if (_isSaving)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//             )
//           else
//             IconButton(
//               icon: const Icon(Icons.check),
//               onPressed: () => _saveNote(),
//               tooltip: 'Save',
//             ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             // Title field
//             TextFormField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 labelText: 'Title',
//                 hintText: 'Enter note title',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.title),
//               ),
//               textCapitalization: TextCapitalization.sentences,
//               validator: (value) {
//                 if (value == null || value.trim().isEmpty) {
//                   return 'Title cannot be empty';
//                 }
//                 return null;
//               },
//               maxLength: 100,
//             ),
//             const SizedBox(height: 16),

//             // Content field
//             TextFormField(
//               controller: _contentController,
//               decoration: InputDecoration(
//                 labelText: 'Content',
//                 hintText: 'Write your note here...',
//                 border: const OutlineInputBorder(),
//                 alignLabelWithHint: true,
//                 suffixIcon: settings.showWordCount
//                     ? Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Text(
//                           '$_wordCount words',
//                           style: Theme.of(context).textTheme.labelSmall,
//                         ),
//                       )
//                     : null,
//               ),
//               textCapitalization: TextCapitalization.sentences,
//               maxLines: 12,
//               minLines: 8,
//             ),
//             const SizedBox(height: 16),

//             // Category field
//             TextFormField(
//               controller: _categoryController,
//               decoration: const InputDecoration(
//                 labelText: 'Category (optional)',
//                 hintText: 'e.g., Work, Personal, Ideas',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.category),
//               ),
//               textCapitalization: TextCapitalization.words,
//             ),
//             const SizedBox(height: 16),

//             // Tags field
//             TextFormField(
//               controller: _tagsController,
//               decoration: const InputDecoration(
//                 labelText: 'Tags (optional)',
//                 hintText: 'e.g., important, work, project',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.label),
//                 helperText: 'Separate tags with commas',
//               ),
//               textCapitalization: TextCapitalization.none,
//             ),
//             const SizedBox(height: 16),

//             // Color selector
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Note Color (optional)',
//                   style: Theme.of(context).textTheme.labelLarge,
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 12,
//                   children: [
//                     // No color option
//                     _buildColorChip(context, null, 'None'),
//                     // Color options
//                     ..._colorOptions.map(
//                       (color) => _buildColorChip(context, color, color),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // Save button (alternative to app bar button)
//             FilledButton.icon(
//               onPressed: _isSaving ? null : () => _saveNote(),
//               icon: _isSaving
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : const Icon(Icons.save),
//               label: Text(isEditing ? 'Update Note' : 'Save Note'),
//               style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildColorChip(BuildContext context, String? color, String label) {
//     final isSelected = _selectedColor == color;
//     Color chipColor;

//     if (color == null) {
//       chipColor = Theme.of(context).colorScheme.surfaceContainerHighest;
//     } else {
//       switch (color) {
//         case 'red':
//           chipColor = Colors.red.shade100;
//           break;
//         case 'blue':
//           chipColor = Colors.blue.shade100;
//           break;
//         case 'green':
//           chipColor = Colors.green.shade100;
//           break;
//         case 'yellow':
//           chipColor = Colors.yellow.shade100;
//           break;
//         case 'purple':
//           chipColor = Colors.purple.shade100;
//           break;
//         case 'orange':
//           chipColor = Colors.orange.shade100;
//           break;
//         default:
//           chipColor = Theme.of(context).colorScheme.surfaceContainerHighest;
//       }
//     }

//     return ChoiceChip(
//       label: Text(
//         label[0].toUpperCase() + label.substring(1),
//         style: TextStyle(
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//       selected: isSelected,
//       onSelected: (selected) {
//         setState(() {
//           _selectedColor = selected ? color : null;
//         });
//       },
//       backgroundColor: chipColor,
//       selectedColor: chipColor,
//       side: BorderSide(
//         color: isSelected
//             ? Theme.of(context).colorScheme.primary
//             : Colors.transparent,
//         width: 2,
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noteale_v2/model/note.dart';
import 'package:noteale_v2/providers/note_provider.dart';
import 'package:noteale_v2/providers/setting_provider.dart';
import 'package:noteale_v2/screens/home_screen.dart';
import 'package:provider/provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isEditable = false;
  bool _isSaving = false;
  Timer? _autoSaveTimer;

  // Local mutable copy of note (IMPORTANT FIX)
  Note? _note;

  String? _selectedColor;
  String? _selectedCategory;

  final List<String> _colorOptions = [
    'red',
    'blue',
    'green',
    'yellow',
    'purple',
    'orange',
  ];

  final List<String> _categories = [
    'Work',
    'Personal',
    'Ideas',
    'Important',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    // Store the note locally so we can update it
    _note = widget.note;

    final combined = _note != null
        ? _note!.title +
              (_note!.content.isNotEmpty ? '\n${_note!.content}' : '')
        : '';

    _controller = TextEditingController(text: combined);

    _selectedColor = _note?.color;
    _selectedCategory = _note?.category;

    // Auto-save setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      if (settings.autoSave) {
        _startAutoSave(settings.autoSaveInterval);
      }
    });
  }

  void _startAutoSave(int seconds) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(Duration(seconds: seconds), (_) {
      if (_controller.text.trim().isNotEmpty) {
        _saveNote(showSnackbar: false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveNote({bool showSnackbar = true}) async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final lines = _controller.text.split('\n');
      final title = lines.first.trim().isEmpty
          ? "Untitled"
          : lines.first.trim();
      final content = lines.length > 1
          ? lines.sublist(1).join('\n').trim()
          : '';

      final now = DateTime.now();

      final note = Note(
        id: _note?.id,
        title: title,
        content: content,
        color: _selectedColor,
        category: _selectedCategory,
        createdAt: _note?.createdAt ?? now,
        updatedAt: now,
        isPinned: _note?.isPinned ?? false,
        isFavorite: _note?.isFavorite ?? false,
      );

      final notesProvider = context.read<NotesProvider>();

      if (_note == null) {
        // CREATE NOTE
        final newId = await notesProvider.addNote(note);

        // Store updated note (with new ID)
        setState(() {
          _note = note.copyWith(id: newId.id);
        });

        if (mounted && showSnackbar) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note created')));
        }
      } else {
        // UPDATE EXISTING NOTE
        await notesProvider.updateNote(note);

        if (mounted && showSnackbar) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note updated')));
        }
      }

      if (mounted && showSnackbar) {
        // Navigator.pop(context);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false, // ← removes all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _enableEditing() {
    setState(() => _isEditable = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  int get _wordCount {
    final text = _controller.text.trim();
    return text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  }

  Widget _buildColorChip(String? color, String label) {
    final isSelected = _selectedColor == color;

    final chipColor = color == null
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : {
            'red': Colors.red.shade100,
            'blue': Colors.blue.shade100,
            'green': Colors.green.shade100,
            'yellow': Colors.yellow.shade100,
            'purple': Colors.purple.shade100,
            'orange': Colors.orange.shade100,
          }[color]!;

    return ChoiceChip(
      label: Text(
        label[0].toUpperCase() + label.substring(1),
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedColor = selected ? color : null);
      },
      backgroundColor: chipColor,
      selectedColor: chipColor,
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        width: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return GestureDetector(
      onTap: _isEditable ? null : _enableEditing,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Freehand Note'),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(icon: const Icon(Icons.check), onPressed: _saveNote),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // CATEGORY
              Row(
                children: [
                  const Text(
                    'Category:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('Select category'),
                    items: _categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // COLORS
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       _buildColorChip(null, 'None'),
              //       ..._colorOptions.map(
              //         (c) => Padding(
              //           padding: const EdgeInsets.only(left: 8.0),
              //           child: _buildColorChip(c, c),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // const SizedBox(height: 16),

              // TEXT FIELD
              Expanded(
                child: AbsorbPointer(
                  absorbing: !_isEditable,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _isEditable
                          ? "Start writing your note..."
                          : "Tap anywhere to edit...",
                      suffixIcon: settings.showWordCount
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '$_wordCount words',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
