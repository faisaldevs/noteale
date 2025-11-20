import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noteale_v2/model/note.dart';
import 'package:noteale_v2/providers/note_provider.dart';
import 'package:noteale_v2/providers/setting_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'add_edit_note_screen.dart';

/// Screen displaying full details of a note
class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  /// Delete note with confirmation
  Future<void> _deleteNote(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    
    bool confirmed = true;
    if (settings.confirmDelete) {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
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
      ) ?? false;
    }

    if (confirmed && context.mounted) {
      try {
        await context.read<NotesProvider>().deleteNote(note.id!);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting note: $e')),
          );
        }
      }
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate Note'),
              onTap: () async {
                Navigator.pop(context);
                await context.read<NotesProvider>().duplicateNote(note);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note duplicated')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_all),
              title: const Text('Copy to Clipboard'),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: '${note.title}\n\n${note.content}'),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Share functionality would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromString(String? colorStr) {
    if (colorStr == null) return Colors.transparent;
    switch (colorStr) {
      case 'red':
        return Colors.red.shade50;
      case 'blue':
        return Colors.blue.shade50;
      case 'green':
        return Colors.green.shade50;
      case 'yellow':
        return Colors.yellow.shade50;
      case 'purple':
        return Colors.purple.shade50;
      case 'orange':
        return Colors.orange.shade50;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final settings = context.watch<SettingsProvider>();
    final backgroundColor = _getColorFromString(note.color);

    return Scaffold(
      backgroundColor: backgroundColor != Colors.transparent
          ? backgroundColor
          : null,
      appBar: AppBar(
        backgroundColor: backgroundColor != Colors.transparent
            ? backgroundColor
            : null,
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: Icon(
              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            onPressed: () {
              context.read<NotesProvider>().togglePin(note);
            },
            tooltip: note.isPinned ? 'Unpin' : 'Pin',
          ),
          IconButton(
            icon: Icon(
              note.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: note.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              context.read<NotesProvider>().toggleFavorite(note);
            },
            tooltip: note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditNoteScreen(note: note),
                ),
              );
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
            tooltip: 'More',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteNote(context),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Date info
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Created: ${dateFormat.format(note.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.update,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated: ${dateFormat.format(note.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),

            // Word and character count
            if (settings.showWordCount) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.text_fields,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${note.wordCount} words • ${note.characterCount} characters',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],

            // Category
            if (note.category != null && note.category!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      note.category!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
            ],

            // Tags
            if (note.tags != null && note.tags!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: note.tags!.split(',').map((tag) {
                  return Chip(
                    label: Text(tag.trim()),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],

            const Divider(height: 32),

            // Content
            SelectableText(
              note.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}