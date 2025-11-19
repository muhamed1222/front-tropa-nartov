import 'package:equatable/equatable.dart';

class PlaceArea extends Equatable {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  const PlaceArea({required this.id, required this.name, required this.description, required this.isActive});

  @override
  List<Object?> get props => [id, name, description];
}
