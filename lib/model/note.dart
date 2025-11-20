/// Model class representing a Note
class Note {
  final int? id;
  final String title;
  final String content;
  final String? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final String? color;
  final bool isFavorite;
  final String? category;
  final List<String>? attachments;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.color,
    this.isFavorite = false,
    this.category,
    this.attachments,
  });

  /// Convert Note object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned ? 1 : 0,
      'color': color,
      'isFavorite': isFavorite ? 1 : 0,
      'category': category,
      'attachments': attachments?.join('|'),
    };
  }

  /// Create Note object from Map (database query result)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      tags: map['tags'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isPinned: (map['isPinned'] as int?) == 1,
      color: map['color'] as String?,
      isFavorite: (map['isFavorite'] as int?) == 1,
      category: map['category'] as String?,
      attachments: map['attachments'] != null
          ? (map['attachments'] as String).split('|')
          : null,
    );
  }

  /// Create a copy of Note with updated fields
  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? color,
    bool? isFavorite,
    String? category,
    List<String>? attachments,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
    );
  }

  /// Get preview text (first few lines of content)
  String getPreview({int maxLength = 100}) {
    if (content.isEmpty) return 'No content';
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  /// Get word count
  int get wordCount => content.trim().split(RegExp(r'\s+')).length;

  /// Get character count
  int get characterCount => content.length;
}