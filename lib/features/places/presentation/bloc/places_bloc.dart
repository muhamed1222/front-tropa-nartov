import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'places_event.dart';
part 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  PlacesBloc() : super(PlacesInitial()) {
    on<PlacesEvent>((event, emit) {

    });
  }
}
