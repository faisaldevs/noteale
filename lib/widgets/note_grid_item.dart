import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noteale_v2/model/note.dart';
import 'package:noteale_v2/screens/note_details_screen.dart';

/// Grid item widget for displaying a note in grid view
class NoteGridItem extends StatelessWidget {
  final Note note;

  const NoteGridItem({super.key, required this.note});

  Color _getColorFromString(String? colorStr) {
    if (colorStr == null) return Colors.transparent;
    switch (colorStr) {
      case 'red':
        return Colors.red.shade100;
      case 'blue':
        return Colors.blue.shade100;
      case 'green':
        return Colors.green.shade100;
      case 'yellow':
        return Colors.yellow.shade100;
      case 'purple':
        return Colors.purple.shade100;
      case 'orange':
        return Colors.orange.shade100;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final theme = Theme.of(context);
    final backgroundColor = _getColorFromString(note.color);

    return Card(
      color: backgroundColor != Colors.transparent
          ? backgroundColor
          : theme.cardTheme.color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icons
              Row(
                children: [
                  if (note.isPinned)
                    Icon(
                      Icons.push_pin,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  if (note.isPinned) const SizedBox(width: 4),
                  if (note.isFavorite)
                    Icon(Icons.favorite, size: 16, color: Colors.red),
                  const Spacer(),
                  Text(
                    dateFormat.format(note.updatedAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                note.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Content preview
              Expanded(
                child: Text(
                  note.getPreview(maxLength: 80),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Category tag
              if (note.category != null && note.category!.isNotEmpty) ...[
                const SizedBox(height: 8),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
