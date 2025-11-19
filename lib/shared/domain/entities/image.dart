class Image {
  final String id;
  final String url;
  final String createdAt;
  final String updatedAt;

  const Image({
    required this.id,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    print('=== IMAGE.FROMJSON DEBUG ===');
    print('Image JSON keys: ${json.keys.toList()}');
    print('URL field value: ${json['URL']}');
    print('url field value: ${json['url']}');

    // Пробуем разные варианты имени поля
    final String imageUrl = json['URL']?.toString() ??
        json['url']?.toString() ??
        '';

    print('Selected URL: "$imageUrl"');
    print('==========================');

    return Image(
      id: json['ID']?.toString() ?? json['id']?.toString() ?? '',
      url: imageUrl,
      createdAt: json['CreatedAt']?.toString() ?? json['created_at']?.toString() ?? '',
      updatedAt: json['UpdatedAt']?.toString() ?? json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}