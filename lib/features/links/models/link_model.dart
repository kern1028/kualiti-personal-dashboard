import 'dart:typed_data';

class LinkModel {
  final int? id;
  final String name;
  final String url;
  final Uint8List? iconBlob;
  final bool showOnHome;
  final int sortOrder;

  LinkModel({
    this.id,
    required this.name,
    required this.url,
    this.iconBlob,
    this.showOnHome = true,
    this.sortOrder = 0,
  });

  String get normalizedUrl {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return 'https://';
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  String get initialLetter {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      return trimmed[0].toUpperCase();
    }
    return 'L';
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'url': normalizedUrl,
      'icon_blob': iconBlob,
      'show_on_home': showOnHome ? 1 : 0,
      'sort_order': sortOrder,
    };
  }

  factory LinkModel.fromMap(Map<String, dynamic> map) {
    return LinkModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      url: map['url'] as String,
      iconBlob: map['icon_blob'] as Uint8List?,
      showOnHome: (map['show_on_home'] as int? ?? 0) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  LinkModel copyWith({
    int? id,
    String? name,
    String? url,
    Uint8List? iconBlob,
    bool? showOnHome,
    int? sortOrder,
  }) {
    return LinkModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      iconBlob: iconBlob ?? this.iconBlob,
      showOnHome: showOnHome ?? this.showOnHome,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
