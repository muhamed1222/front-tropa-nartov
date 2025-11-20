import '../../../core/utils/logger.dart';

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
    AppLogger.debug('=== IMAGE.FROMJSON DEBUG ===');
    AppLogger.debug('Image JSON keys: ${json.keys.toList()}');
    AppLogger.debug('URL field value: ${json['URL']}');
    AppLogger.debug('url field value: ${json['url']}');

    // Пробуем разные варианты имени поля
    final String imageUrl = json['URL']?.toString() ??
        json['url']?.toString() ??
        '';

    AppLogger.debug('Selected URL: "$imageUrl"');
    AppLogger.debug('==========================');

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