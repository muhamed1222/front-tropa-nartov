import 'package:equatable/equatable.dart';

class PlaceRegion extends Equatable {
  final int id;
  final String name;
  final String description;
  final bool isOpen;
  final bool isActive;

  const PlaceRegion({required this.id, required this.name, required this.description, required this.isActive, required this.isOpen});

  @override
  List<Object?> get props => [id, name, description, isActive, isOpen];
}
