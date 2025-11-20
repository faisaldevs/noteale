import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noteale_v2/model/note.dart';
import 'package:noteale_v2/providers/note_provider.dart';
import 'package:noteale_v2/screens/note_details_screen.dart';
import 'package:provider/provider.dart';

/// Card widget displaying a note in the list
class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  Color _getColorFromString(String? colorStr, BuildContext context) {
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
    final dateFormat = DateFormat('MMM dd, yyyy');
    final theme = Theme.of(context);
    final backgroundColor = _getColorFromString(note.color, context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: backgroundColor != Colors.transparent
          ? backgroundColor
          : theme.cardTheme.color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: note.isPinned
              ? theme.colorScheme.primary.withOpacity(0.5)
              : theme.colorScheme.outlineVariant,
          width: note.isPinned ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(note: note),
            ),
          );
        },
        onLongPress: () => _showBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Pin indicator
                  if (note.isPinned)
                    Icon(
                      Icons.push_pin,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  if (note.isPinned) const SizedBox(width: 8),

                  // Title
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Favorite icon
                  IconButton(
                    icon: Icon(
                      note.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: note.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      context.read<NotesProvider>().toggleFavorite(note);
                    },
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content preview
              if (note.content.isNotEmpty)
                Text(
                  note.getPreview(maxLength: 120),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),

              // Bottom row: Category, Tags, and Date
              Row(
                children: [
                  // Category
                  if (note.category != null && note.category!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        note.category!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Tags
                  if (note.tags != null && note.tags!.isNotEmpty) ...[
                    Flexible(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: note.tags!
                            .split(',')
                            .take(2)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag.trim(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  const Spacer(),

                  // Date
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(note.updatedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              title: Text(note.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                context.read<NotesProvider>().togglePin(note);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                note.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              title: Text(
                note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              ),
              onTap: () {
                context.read<NotesProvider>().toggleFavorite(note);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () async {
                await context.read<NotesProvider>().duplicateNote(note);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note duplicated')),
                  );
                }
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
}
