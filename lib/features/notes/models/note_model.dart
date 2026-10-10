import 'dart:convert';

class NoteBlock {
  String type; // 'paragraph', 'heading', 'bullet', 'number', 'alpha'
  String text;
  bool bold;
  bool italic;
  bool underline;
  String? link;

  NoteBlock({
    this.type = 'paragraph',
    this.text = '',
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.link,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'bold': bold,
      'italic': italic,
      'underline': underline,
      'link': link,
      if (type == 'alpha') 'style': 'lower-alpha',
    };
  }

  factory NoteBlock.fromJson(Map<String, dynamic> json) {
    final blockType = json['type'] as String? ?? 'paragraph';
    return NoteBlock(
      type: (blockType == 'number' && json['style'] == 'lower-alpha')
          ? 'alpha'
          : blockType,
      text: json['text'] as String? ?? '',
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      underline: json['underline'] as bool? ?? false,
      link: json['link'] as String?,
    );
  }
}

class NoteModel {
  final int? id;
  final String title;
  final String bodyJson;
  final String plainText;
  final bool pinned;
  final String tags; // comma separated
  final String updatedAt;
  final String createdAt;

  NoteModel({
    this.id,
    required this.title,
    required this.bodyJson,
    required this.plainText,
    this.pinned = false,
    this.tags = '',
    required this.updatedAt,
    required this.createdAt,
  });

  List<String> get tagList {
    if (tags.trim().isEmpty) return [];
    return tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(5)
        .toList();
  }

  String get snippet {
    if (plainText.trim().isEmpty) return 'Belum ada isi catatan';
    final trimmed = plainText.trim().replaceAll('\n', ' ');
    if (trimmed.length > 80) {
      return '${trimmed.substring(0, 80)}...';
    }
    return trimmed;
  }

  static List<NoteBlock> parseBlocks(String jsonStr) {
    if (jsonStr.trim().isEmpty) {
      return [NoteBlock()];
    }
    try {
      final List decoded = json.decode(jsonStr);
      return decoded.map((e) => NoteBlock.fromJson(e)).toList();
    } catch (_) {
      return [NoteBlock(text: jsonStr)];
    }
  }

  static String encodeBlocks(List<NoteBlock> blocks) {
    final list = blocks.map((b) => b.toJson()).toList();
    return json.encode(list);
  }

  static String extractPlainText(List<NoteBlock> blocks) {
    return blocks.map((b) => b.text).where((t) => t.isNotEmpty).join('\n');
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body_json': bodyJson,
      'plain_text': plainText,
      'pinned': pinned ? 1 : 0,
      'tags': tags,
      'updated_at': updatedAt,
      'created_at': createdAt,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      bodyJson: map['body_json'] as String? ?? '[]',
      plainText: map['plain_text'] as String? ?? '',
      pinned: (map['pinned'] as int? ?? 0) == 1,
      tags: map['tags'] as String? ?? '',
      updatedAt: map['updated_at'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  NoteModel copyWith({
    int? id,
    String? title,
    String? bodyJson,
    String? plainText,
    bool? pinned,
    String? tags,
    String? updatedAt,
    String? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      bodyJson: bodyJson ?? this.bodyJson,
      plainText: plainText ?? this.plainText,
      pinned: pinned ?? this.pinned,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
