import 'package:equatable/equatable.dart';

class PlaceCategory extends Equatable {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  const PlaceCategory({required this.id, required this.name, required this.description, required this.isActive});

  @override
  List<Object?> get props => [id, name, description];
}
