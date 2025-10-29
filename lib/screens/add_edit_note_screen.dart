import 'package:flutter/material.dart';
import 'package:noteale_v2/model/note.dart';
import 'package:noteale_v2/providers/note_provider.dart';
import 'package:provider/provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      // Combine title and content into single controller
      final combined =
          widget.note!.title +
          (widget.note!.content.isNotEmpty ? '\n${widget.note!.content}' : '');
      _controller.text = combined;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final lines = _controller.text.split('\n');
      final title = lines.isNotEmpty ? lines.first.trim() : 'Untitled';
      final content = lines.length > 1
          ? lines.sublist(1).join('\n').trim()
          : '';

      final now = DateTime.now();
      final note = Note(
        id: widget.note?.id,
        title: title,
        content: content,
        createdAt: widget.note?.createdAt ?? now,
        updatedAt: now,
      );

      final notesProvider = context.read<NotesProvider>();

      if (widget.note == null) {
        await notesProvider.addNote(note);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note created')));
        }
      } else {
        await notesProvider.updateNote(note);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note updated')));
        }
      }

      if (mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freehand Note'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
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
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 18),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Start writing your note...',
          ),
        ),
      ),
    );
  }
}
