/// Model class representing a Note
class Note {
  final int? id;
  final String title;
  final String content;
  final String? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
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
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get preview text (first few lines of content)
  String getPreview({int maxLength = 100}) {
    if (content.isEmpty) return 'No content';
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
}