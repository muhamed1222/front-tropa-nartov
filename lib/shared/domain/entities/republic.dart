import 'package:equatable/equatable.dart';

class Republic extends Equatable {
  final String name;
  final String imagePath;
  final bool isAvailable;

  const Republic({
    required this.name,
    required this.imagePath,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [name, imagePath, isAvailable];

  Map<String, dynamic> toJson() => {
        'name': name,
        'imagePath': imagePath,
        'isAvailable': isAvailable,
      };

  factory Republic.fromJson(Map<String, dynamic> json) => Republic(
        name: json['name'] as String,
        imagePath: json['imagePath'] as String,
        isAvailable: json['isAvailable'] as bool,
      );
}

